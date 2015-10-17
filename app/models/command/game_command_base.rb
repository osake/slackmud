module Command
  class GameCommandBase
    extend Forwardable

    attr_reader :slack_request_text,
                :quantity,
                :command,
                :target,
                :arguments,
                :slack_text_array,
                :game
    def_delegators :@game,
                   :slack_messenger,
                   :room,
                   :player

    def initialize(game)
      @game             = game
      @slack_text_array = game.slack_request.text.split
      @command          = @slack_text_array.shift
      @quantity         = extract_quantity
      @target           = extract_target
      @arguments        = @slack_text_array.join(' ')
    end

    private

    def target?
      @target.nil?
    end

    def extract_target
      return @slack_text_array.pop if @slack_text_array.length > 1
    end

    def extract_quantity
      return 1 if @slack_text_array.first.to_i == 0
      @slack_text_array.shift.to_i
    end
  end
end
