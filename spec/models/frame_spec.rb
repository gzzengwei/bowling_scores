require 'rails_helper'

RSpec.describe Frame, type: :model do

  let(:frame_round) { 1 }

  describe '#strike?' do
    let(:frame) { Frame.new({round: frame_round}.merge(frame_rolls)) }

    subject { frame.strike? }

    context 'when roll_1 is 10' do
      let(:frame_rolls) { {roll_1: 10, roll_2: nil, roll_3: nil}}
      it { is_expected.to be_truthy }
    end

    context 'when roll_1 is 1' do
      let(:frame_rolls) { {roll_1: 1, roll_2: nil, roll_3: nil}}
      it { is_expected.to be_falsey }
    end
  end

  describe '#spare?' do
    let(:frame) { Frame.new({round: frame_round}.merge(frame_rolls)) }
    subject { frame.spare? }

    context 'when roll_1 is 4, roll_2 is 6' do
      let(:frame_rolls) { {roll_1: 4, roll_2: 6, roll_3: nil}}
      it { is_expected.to be_truthy }
    end

    context 'when roll_1 is 10, roll_2 is 0' do
      let(:frame_rolls) { {roll_1: 10, roll_2: 0, roll_3: nil}}
      it { is_expected.to be_falsey }
    end
  end

  describe '#played?' do
    let(:frame) { Frame.new({round: frame_round}.merge(frame_rolls)) }

    subject { frame.played? }

    context 'frame 1' do
      context 'when roll_1 is 4, roll_2 is nil' do
        let(:frame_rolls) { {roll_1: 4, roll_2: nil, roll_3: nil}}
        it { is_expected.to be_falsey }
      end

      context 'when strike' do
        let(:frame_rolls) { {roll_1: 10, roll_2: nil, roll_3: nil}}
        it { is_expected.to be_truthy }
      end

      context 'when spare' do
        let(:frame_rolls) { {roll_1: 2, roll_2: 8, roll_3: nil}}
        it { is_expected.to be_truthy }
      end
    end

    context 'frame 10' do
      let(:frame_round) { 10 }

      context 'when strike without roll 2/3' do
        let(:frame_rolls) { {roll_1: 10, roll_2: nil, roll_3: nil}}
        it { is_expected.to be_falsey }
      end

      context 'when strike with roll 2 and without roll 3' do
        let(:frame_rolls) { {roll_1: 10, roll_2: 8, roll_3: nil} }
        it { is_expected.to be_falsey }
      end

      context 'when strike with roll 2/3' do
        let(:frame_rolls) { {roll_1: 10, roll_2: 10, roll_3: 10} }
        it { is_expected.to be_truthy }
      end

      context 'when strike with roll 2/3' do
        let(:frame_rolls) { {roll_1: 10, roll_2: 8, roll_3: nil} }
        it { is_expected.to be_falsey }
      end

      context 'when spare without roll 3' do
        let(:frame_rolls) { {roll_1: 2, roll_2: 8, roll_3: nil} }
        it { is_expected.to be_falsey }
      end

      context 'when spare with roll 3' do
        let(:frame_rolls) { {roll_1: 2, roll_2: 8, roll_3: 8} }
        it { is_expected.to be_truthy }
      end

    end
  end

  describe '#bonus_score' do
    let(:game) { Game.new }
    let(:player) { Player.create(name: 'Player', game: game)}
    let(:frame_1) { player.frames.create({round: frame_1_round}.merge(frame_1_rolls)) }
    let(:frame_2) { player.frames.create({round: frame_1_round + 1}.merge(frame_2_rolls)) }
    let(:frame_3) { player.frames.create({round: frame_1_round + 2}.merge(frame_3_rolls)) }
    let(:frame_1_round) { 1 }
    let(:frame_1_rolls) { {roll_1: 10, roll_2: nil, roll_3: nil}}
    let(:frame_2_rolls) { {roll_1: 1, roll_2: 1, roll_3: nil}}
    let(:frame_3_rolls) { {roll_1: 3, roll_2: 3, roll_3: nil}}

    subject { frame_1.bonus_score }

    context 'frame 1-8' do

      before { frame_1 ; frame_2 ; frame_3 }

      context 'when not strike/spare' do
        let(:frame_1_rolls) { {roll_1: 1, roll_2: 1, roll_3: nil}}
        it { is_expected.to eq(0) }
      end

      context 'when strike' do
        let(:frame_1_rolls) { {roll_1: 10, roll_2: nil, roll_3: nil}}
        context 'frame 2 is strike' do
          let(:frame_2_rolls) { {roll_1: 10, roll_2: nil, roll_3: nil}}
          it 'sum of frame 2 roll 1 and frame 3 roll 1' do
            expect(subject).to eq(13)
          end
        end

        context 'frame 2 is not strike' do
          let(:frame_2_rolls) { {roll_1: 1, roll_2: 1, roll_3: nil}}
          it 'sum of frame 2 roll 1 and roll 2' do
            expect(subject).to eq(2)
          end
        end
      end

      context 'when spare' do
        let(:frame_1_rolls) { {roll_1: 1, roll_2: 9, roll_3: nil}}
        it 'is frame 2 roll 1' do
          expect(subject).to eq(1)
        end
      end
    end

    context 'frame 9' do
      let(:frame_1_round) { 9 }
      before { frame_1 ; frame_2 }
      context 'when strike' do
        let(:frame_1_rolls) { {roll_1: 10, roll_2: nil, roll_3: nil}}
        context 'last frame strike' do
          let(:frame_2_rolls) { {roll_1: 10, roll_2: 1, roll_3: nil}}
          it 'sum of last frame roll 1 and roll 2' do
            expect(subject).to eq(11)
          end
        end
      end
    end

    context 'frame 10' do
      let(:frame_1_round) { 10 }
      before {
        allow(frame_1).to receive_messages(update_player_status: true)
      }
      context 'when strike' do
        let(:frame_1_rolls) { {roll_1: 10, roll_2: 10, roll_3: 9}}
        it 'roll 3' do
          expect(subject).to eq(9)
        end
      end

      context 'when spare' do
        let(:frame_1_rolls) { {roll_1: 1, roll_2: 9, roll_3: 9}}
        it 'roll 3' do
          expect(subject).to eq(9)
        end
      end
    end
  end

end
