require 'spec_helper'

describe Game do
  describe "when create" do
    context "with correct data" do
      let(:game) { create(:game) }
      subject { game }

      it { should be_valid }
      its(:name) { should == "#{game.club_home.name} - #{game.club_away.name}" }
      its(:home_goals) { should eql 0 }
      its(:away_goals) { should eql 0 }
    end

    context "after a find" do
      let(:game) { create(:game) }
      before { game }
      subject { Game.find game }

      its(:name) { should == "#{game.club_home.name} - #{game.club_away.name}" }
    end

    context "without date" do
      let(:game) { build(:game, date: nil) }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:date) }
      it { game.error_on(:date).should include I18n.t('errors.messages.blank') }
    end

    context "without status" do
      let(:game) { build(:game, status: nil) }
      subject { game }

      it { should_not be_valid }
      it { should have(2).error_on(:status) }
      it { game.error_on(:status).should include I18n.t('errors.messages.blank') }
      it { game.error_on(:status).should include I18n.t('errors.messages.inclusion') }
    end

    context "without week" do
      let(:game) { build(:game, week: nil) }
      subject { game }

      it { should_not be_valid }
      it { should have(3).error_on(:week) }
      it { game.error_on(:week).should include I18n.t('errors.messages.blank') }
      it { game.error_on(:week).should include I18n.t('errors.messages.not_a_number') }
      it { game.error_on(:week).should include I18n.t('errors.messages.too_short', count: 1) }
    end

    context "with not number week" do
      let(:game) { build(:game, week: 'a') }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { game.error_on(:week).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with float week" do
      let(:game) { build(:game, week: '.1') }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { game.error_on(:week).should include I18n.t('errors.messages.not_an_integer') }
    end

    context "with week less than 0" do
      let(:game) { build(:game, week: -1) }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { game.error_on(:week).should include I18n.t('errors.messages.greater_than', count: 0) }
    end

    context "with week more than two dgits" do
      let(:game) { build(:game, week: 100) }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { game.error_on(:week).should include I18n.t('errors.messages.too_long', count: 2) }
    end

    context "without season" do
      let(:game) { build(:game, season: nil) }
      subject { game }

      it { should_not be_valid }
      it { should have(3).error_on(:season) }
      it { game.error_on(:season).should include I18n.t('errors.messages.blank') }
      it { game.error_on(:season).should include I18n.t('errors.messages.not_a_number') }
      it { game.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "with not number season" do
      let(:game) { build(:game, season: 'a') }
      subject { game }

      it { should_not be_valid }
      it { should have(2).error_on(:season) }
      it { game.error_on(:season).should include I18n.t('errors.messages.not_a_number') }
      it { game.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "with float season" do
      let(:game) { build(:game, season: '1111.1') }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:season) }
      it { game.error_on(:season).should include I18n.t('errors.messages.not_an_integer') }
    end

    context "with season less than 0" do
      let(:game) { build(:game, season: -1) }
      subject { game }

      it { should_not be_valid }
      it { should have(2).error_on(:season) }
      it { game.error_on(:season).should include I18n.t('errors.messages.greater_than', count: 0) }
      it { game.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "with season less than four digits" do
      let(:game) { build(:game, season: 100) }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:season) }
      it { game.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "with season more than four digits" do
      let(:game) { build(:game, season: 10000) }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:season) }
      it { game.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "without clubs in same league" do
      let(:club) { build(:club) }
      let(:game) { build(:game, club_home: club) }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:club_home) }
      it { game.error_on(:club_home).should include I18n.t('activerecord.errors.models.game.attributes.club_home.should_play_same_league') }
      it { should have(1).error_on(:club_away) }
      it { game.error_on(:club_away).should include I18n.t('activerecord.errors.models.game.attributes.club_away.should_play_same_league') }
    end

    context "with same club" do
      let(:game) { build(:game) }
      before { game.club_away = game.club_home }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:club_home) }
      it { game.error_on(:club_home).should include I18n.t('activerecord.errors.models.game.attributes.club_home.cant_play_himself') }
    end

    context "with one home goals" do
      let(:game) { create(:game) }
      let(:goal) { create(:goal, game: game) }
      before { goal }
      subject { game }

      it { should be_valid }
      its(:home_goals) { should eql 1 }
      its(:away_goals) { should eql 0 }
    end

    context "with home goals" do
      let(:game) { create(:game) }
      let(:goal) { create(:goal, game: game) }
      let(:second_goal) { create(:goal, game: game) }
      before { goal; second_goal }
      subject { game }

      it { should be_valid }
      its(:home_goals) { should eql 2 }
      its(:away_goals) { should eql 0 }
    end

    context "with one away goals" do
      let(:game) { create(:game) }
      let(:scorer) { create(:player_with_club, player_club: game.club_away) }
      let(:goal) { create(:goal, game: game, scorer: scorer) }
      before { goal }
      subject { game }

      it { should be_valid }
      its(:home_goals) { should eql 0 }
      its(:away_goals) { should eql 1 }
    end

    context "with away goals" do
      let(:game) { create(:game) }
      let(:scorer) { create(:player_with_club, player_club: game.club_away) }
      let(:goal) { create(:goal, game: game, scorer: scorer) }
      let(:second_goal) { create(:goal, game: game, scorer: scorer) }
      before { goal; second_goal }
      subject { game }

      it { should be_valid }
      its(:home_goals) { should eql 0 }
      its(:away_goals) { should eql 2 }
    end

    context "with away goals" do
      let(:game) { create(:game) }
      let(:home_scorer) { create(:player_with_club, player_club: game.club_home) }
      let(:away_scorer) { create(:player_with_club, player_club: game.club_away) }
      let(:goal) { create(:goal, game: game, scorer: home_scorer) }
      let(:second_goal) { create(:goal, game: game, scorer: home_scorer) }
      let(:third_goal) { create(:goal, game: game, scorer: away_scorer) }
      before { goal; second_goal; third_goal }
      subject { game }

      it { should be_valid }
      its(:home_goals) { should eql 2 }
      its(:away_goals) { should eql 1 }
    end

    context "with players" do
      let(:player) { create(:player_with_club) }
      let(:game) { create(:game_from_club_home, club_home: player.club) }
      subject { game }

      it { game.player_in_club_home?(player).should be_true }
      it { game.player_in_club_away?(player).should_not be_true }
    end
  end
end
