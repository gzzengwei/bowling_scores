class Game < ActiveRecord::Base
  has_many :players
  accepts_nested_attributes_for :players, reject_if: :all_blank, allow_destroy: true

  def status
    finished? ? 'Finished' : 'New'
  end

  def update_winner
    update(winner: player_winner.name) if finished?
  end

  def finished?
    players.all?(&:finished?)
  end

  private

  def player_winner
    players.detect(&:winner?)
  end

end
