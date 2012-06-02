class Goal < ActiveRecord::Base
  include Extensions::GameEvent
  acts_as_game_event player_relation: :scorer

  belongs_to :assistant, class_name: 'Player'

  include Enumerize
  enumerize :kind, in: %w(regular own penalty penalty_saved penalty_out), default: 'regular'

  validates :minute,  presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 0, :less_than_or_equal_to => 130 }
  validates :kind,  presence: true, inclusion: { in: Goal.kind.values }

  validates :assistant, player_in_game: true, unless: "assistant.blank?"
  validate :validate_assistant_clubs, unless: "assistant.blank?"

  scope :club, ->(club) { joins(:scorer => :club_files).where(club_files: {club_id: club}) }

  def kind_enum
    Goal.kind.values
  end

  def title
    "#{self.scorer_file.club_name}, #{self.scorer.name} (#{self.minute}')"
  end

  def same_player?
    scorer == assistant
  end

  def same_club?
    scorer_file.club == assistant_file.club unless scorer_file.blank? || assistant_file.blank?
  end

  def validate_assistant_clubs
    errors.add(:assistant, :should_be_in_same_club) unless same_club?
    errors.add(:assistant, :should_be_diferent) if same_player?
  end

  def scorer_file
    scorer.club_files.on(game.end_date_of_week).last
  end

  def assistant_file
    assistant.club_files.on(game.end_date_of_week).last
  end
end
