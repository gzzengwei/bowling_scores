class Frame < ActiveRecord::Base
  belongs_to :player

  after_save :update_player_status

  validates :roll_1, :roll_2, :roll_3,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 },
    allow_nil: true

  validate :roll_valid?
  validate :roll_range_valid?
  validate :roll_3_valid?, if: :last_frame?

  MAX = 10

  def strike?
    roll_1.presence == 10
  end

  def spare?
    !strike? && [roll_1, roll_2].map(&:to_i).reduce(&:+) == 10
  end

  def last_frame?
    round == 10
  end

  def played?
    if last_frame?
      if spare? || strike?
        roll_3.present?
      else
        [roll_1, roll_2].all?(&:present?)
      end
    else
      strike? || [roll_1, roll_2].all?(&:present?)
    end
  end

  def wait_for_bonus?
    if last_frame?
      wait_last_frame_bonus?
    else
      wait_general_bonus?
    end
  end

  def score
    basic_score + bonus_score
  end

  def basic_score
    roll_1.to_i + roll_2.to_i
  end

  def bonus_score
    return 0 unless spare? || strike?
    return roll_3.to_i if last_frame?
    s = next_frame.roll_1.to_i
    s += if next_frame.strike? && !next_frame.last_frame?
           next_2_frame.roll_1.to_i
         else
           next_frame.roll_2.to_i
         end if strike?
    s
  end

  def next_frame
    player.frame_of(round + 1)
  end

  def wait_last_frame_bonus?
    if strike?
      return !(roll_2 == 10) && roll_3.blank?
    elsif spare?
      return roll_3.blank?
    end
    false
  end

  private

  def roll_3_valid?
    if !(strike? || spare?) && roll_3.present?
      errors.add(:round, "of Frame #{round} extra Third roll only for strike or spare.")
    end
  end

  def roll_range_valid?
    errors.add(:round, "of Frame #{round} roll total cannot be larger than #{max_score}.") if basic_score > max_score
  end

  def roll_valid?
    if !strike? && roll_2.blank?
      errors.add(:roll_2, "of Frame #{round} must be present unless it is a strike.")
    end
  end

  def max_score
    last_frame? ? 20 : 10
  end

  def next_2_frame
    next_frame.next_frame
  end

  def wait_general_bonus?
    if strike?
      return true if !next_frame.played?
      if next_frame.last_frame?
        return true if next_frame.wait_last_frame_bonus?
      else
        return true if next_frame.strike? && !next_2_frame.played?
        return true if next_frame.spare? && next_2_frame.roll_1.blank?
      end
    elsif spare?
      return true if next_frame.roll_1.blank?
    end
    false
  end

  def update_player_status
    player.update_game_status
  end
end
