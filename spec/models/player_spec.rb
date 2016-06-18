require 'rails_helper'

RSpec.describe Player, type: :model do

  describe '#score_on' do
    let(:game) { Game.create }
    let(:player) { game.players.create(name: 'Player') }

    subject{ player.send :score_on, 10 }

    context 'for 12 strike in a row' do
      before { build_frames(player, :strike) }
      it 'handle strike bonus' do
        expect(subject).to eq(300)
      end
    end

    context 'for spare' do
      before { build_frames(player, :spare) }
      it 'handle spare bonus' do
        expect(subject).to eq(181)
      end
    end

    context 'for others' do
      before { build_frames(player, :random) }
      it 'handle no bonus' do
        expect(subject).to eq(90)
      end
    end
  end

  def build_frames(player, type)
    rolles = case type
             when :strike
               {roll_1: 10, roll_2: nil, roll_3: nil}
             when :spare
               {roll_1: 9, roll_2: 1, roll_3: nil}
             when :random
               {roll_1: 3, roll_2: 6, roll_3: nil}
             end

    1.upto(10).each do |round|
      rolls_hash = rolles
      rolls_hash = rolles.merge(roll_2: 10, roll_3: 10) if round == 10 && type == :strike
      player.frames.create({round: round}.merge(rolls_hash))
    end
  end

end
