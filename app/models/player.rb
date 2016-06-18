class Player < ActiveRecord::Base
  belongs_to :game
  has_many :frames

  accepts_nested_attributes_for :frames, reject_if: :all_blank, allow_destroy: true

  def finished?
    frame_of(10).played?
  end

  def final_score
    score_on(Frame::MAX)
  end

  def score_display(round)
    f = frame_of(round)
    return '__' if f.wait_for_bonus?
    return if !f.played?
    score_on(round)
  end

  def frame_of(round)
    frames.find_or_initialize_by(round: round)
  end

  def update_game_status
    game.update_winner if finished?
  end

  def winner?
    game.finished? && game.players.map(&:final_score).max == self.final_score
  end

  private

  def score_on(round)
    (1..round).inject(0) do |sum, i|
      sum += frame_of(i).score
      sum
    end
  end
end
