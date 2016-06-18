class CreateGameService

  include Interactor

  delegate :game_params, to: :context

  def call
    create_game
    create_frames if @game.persisted?
  ensure
    context.game = @game
  end

  private

  def create_game
    @game = Game.create(game_params)
  end

  def create_frames
    @game.players.find_each do |player|
      1.upto(Frame::MAX).each do |round|
        f = player.frames.new(round: round)
        f.save(validate: false)
      end
    end
  end

end
