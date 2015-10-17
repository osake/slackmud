module Command
  class GameCommand < GameCommandBase
    def commands
      {
        "help": HelpCommand,
        "drop": DropCommand,
        "give": GiveCommand,
        "wear": WearCommand,
        "remove": RemoveCommand,
        "look": LookCommand,
        "examine": LookCommand,
        "get": GetCommand,
        "inventory": InventoryCommand,
        "eat": EatCommand,
        "drink": EatCommand,
        "cast": CastCommand,
        "materialize": MaterializeCommand
      }.with_indifferent_access
    end

    def perform
      return commands[command].new(@game).perform if commands.key? command
      I18n.t 'game.command_not_found'
    end
  end
end
