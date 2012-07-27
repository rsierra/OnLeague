class Game < ActiveRecord::Base
  STATUS_TYPES = %w(active inactive evaluated revised closed)

  STATUS_TRANSITIONS = {
    'active' => ['evaluated','inactive'],
    'inactive' => ['active'],
    'evaluated' => ['revised','active'],
    'revised' => ['closed','evaluated'],
    'closed' => []
    }.freeze

  STATUS_EVENTS = {
    'active' => { 'evaluated' => 'update_players_stats'},
    'evaluated' => { 'active' => 'restore_players_stats'},
    }.freeze

  WINNER_STAT = { points: 1 }
  UNBEATEN_GOALKEEPER_STAT = { points: 2 }
  BEATEN_GOALKEEPER_STAT = { points: 1 }
  UNBEATEN_DEFENDER_STAT = { points: 1 }

  belongs_to :league
  belongs_to :club_home, class_name: 'Club'
  belongs_to :club_away, class_name: 'Club'
  has_many :lineups
  accepts_nested_attributes_for :lineups
  has_many :goals
  accepts_nested_attributes_for :goals
  has_many :cards
  accepts_nested_attributes_for :cards
  has_many :substitutions
  accepts_nested_attributes_for :substitutions

  extend FriendlyId
  friendly_id :custom_slug, use: :slugged

  include Enumerize
  enumerize :status, in: STATUS_TYPES

  validates :league, :club_home, :club_away, presence: true
  validates :date,  presence: true
  validates :status,  presence: true, inclusion: { in: Game.status.values }
  validates :week,  presence: true,
                    numericality: { only_integer: true, greater_than: 0 },
                    length: { minimum: 1, maximum: 2 }
  validates :season,  presence: true,
                      numericality: { only_integer: true, greater_than: 0 },
                      length: { is: 4 }
  validates :slug,  presence: true, uniqueness: true

  validate :validate_play_himself, :validate_clubs_league
  validate :initial_status, if: 'new_record? && !status.blank?'
  validate :new_status, if: 'status_changed? && !new_record?'

  scope :week, ->(week) { where week: week }
  scope :season, ->(season) { where season: season }
  scope :not_closeables, where("status = 'active' OR status = 'evaluated'")

  before_save :trigger_status_events  , if: 'status_changed? && !new_record?'

  def name
    "#{club_home.name} - #{club_away.name}" unless club_home.blank? || club_away.blank?
  end

  def custom_slug
    "#{club_home.name} #{club_away.name} #{season} #{week}"
  end

  def status_enum
    Game.status.values
  end

  def play_himself?
    club_home == club_away
  end

  def club_home_play_league?
    club_home.leagues.include? league
  end

  def club_away_play_league?
    club_home.leagues.include? league
  end

  def home_goals
    goals.of_scorers(club_home.player_ids_on_date(date)).count
  end

  def away_goals
    goals.of_scorers(club_away.player_ids_on_date(date)).count
  end

  def winner_club
    calculated_home_goals = home_goals
    calculated_away_goals = away_goals
    if calculated_home_goals > calculated_away_goals
      club_home
    elsif calculated_home_goals < calculated_away_goals
      club_away
    else
      nil
    end
  end

  def end_date_of_week
    league.end_date_of_week(week,season)
  end

  def result
    status.closed? ? "#{home_goals} - #{away_goals}" : "-"
  end

  def player_in_club_home? player
    club_home.player_ids_on_date(date).include? player.id unless player.blank?
  end

  def player_in_club_away? player
    club_away.player_ids_on_date(date).include? player.id unless player.blank?
  end

  def goalkeeper_in_club_id_on_minute(club_id, minute)
    club = club_id == club_home_id ? club_home : club_away
    club_goalkeeper_ids = club.player_ids_in_position_on_date('goalkeeper',date)
    goalkeeper_lineup = lineups.of_players(club_goalkeeper_ids).first
    goalkeeper = nil
    unless goalkeeper_lineup.blank?
      goalkeeper = goalkeeper_lineup.player
      goalkeeper_substitution = substitutions.of_players_in(club_goalkeeper_ids).before(minute).last
      goalkeeper = goalkeeper_substitution.player_in unless goalkeeper_substitution.blank?
      goalkeeper = nil if goalkeeper.cards.red.before(minute).exists?
    end
    goalkeeper
  end

  def goalkeeper_against_club_id_on_minute(against_club_id, minute)
    club_id = against_club_id == club_home_id ? club_away_id : club_home_id
    goalkeeper_in_club_id_on_minute(club_id, minute)
  end

  def accepted_statuses(status)
    STATUS_TRANSITIONS[status] || []
  end

  def initial_status?
    status.active? || status.inactive?
  end

  def players_who_played(player_ids)
    lineups.of_players(player_ids).map(&:player) +
    substitutions.of_players_in(player_ids).map(&:player_in)
  end

  def players_who_played_of_club(club)
    player_ids = club.player_ids_on_date(date)
    players_who_played(player_ids)
  end

  def players_who_played_of_club_in_position(club, position)
    player_ids = club.player_ids_in_position_on_date(position, date)
    players_who_played(player_ids)
  end

  def update_winners_stats
    club = winner_club
    unless club.blank?
      players_who_played_of_club(club).each do |player|
        player.update_stats(id, WINNER_STAT)
      end
    end
  end

  def update_unbeaten_stats(club)
    players_who_played_of_club_in_position(club,'goalkeeper').each do |player|
      player.update_stats(id, UNBEATEN_GOALKEEPER_STAT)
    end
    players_who_played_of_club_in_position(club,'defender').each do |player|
      player.update_stats(id, UNBEATEN_DEFENDER_STAT)
    end
  end

  def update_beaten_stats(club)
    players_who_played_of_club_in_position(club,'goalkeeper').each do |player|
      player.update_stats(id, BEATEN_GOALKEEPER_STAT)
    end
  end

  def update_defenders_stats(club, goals)
    if goals == 0
      update_unbeaten_stats(club)
    elsif goals == 1
      update_beaten_stats(club)
    end
  end

  def update_players_stats
    update_winners_stats if home_goals != away_goals
    update_defenders_stats(club_home, away_goals) if away_goals < 2
    update_defenders_stats(club_away, home_goals) if home_goals < 2
  end

  def restore_winners_stats
    club = winner_club
    unless club.blank?
      players_who_played_of_club(club).each do |player|
        player.remove_stats(id, WINNER_STAT)
      end
    end
  end

  def restore_unbeaten_stats(club)
    players_who_played_of_club_in_position(club,'goalkeeper').each do |player|
      player.remove_stats(id, UNBEATEN_GOALKEEPER_STAT)
    end
    players_who_played_of_club_in_position(club,'defender').each do |player|
      player.remove_stats(id, UNBEATEN_DEFENDER_STAT)
    end
  end

  def restore_beaten_stats(club)
    players_who_played_of_club_in_position(club,'goalkeeper').each do |player|
      player.remove_stats(id, BEATEN_GOALKEEPER_STAT)
    end
  end

  def restore_defenders_stats(club, goals)
    if goals == 0
      restore_unbeaten_stats(club)
    elsif goals == 1
      restore_beaten_stats(club)
    end
  end

  def restore_players_stats
    restore_winners_stats if home_goals != away_goals
    restore_defenders_stats(club_home, away_goals) if away_goals < 2
    restore_defenders_stats(club_away, home_goals) if home_goals < 2
  end

  private

  def validate_play_himself
    errors.add(:club_home, :cant_play_himself) if play_himself?
  end

  def validate_clubs_league
    errors.add(:club_home, :should_play_same_league) unless club_home_play_league?
    errors.add(:club_away, :should_play_same_league) unless club_away_play_league?
  end

  def initial_status
    errors.add(:status, :should_be_initial_status) unless initial_status?
  end

  def new_status
    errors.add(:status, :should_be_an_accepted_status) unless accepted_statuses(status_was).include? status
  end

  def trigger_status_events
    self.send(STATUS_EVENTS[status_was][status]) if STATUS_EVENTS[status_was] && STATUS_EVENTS[status_was][status]
  end
end
