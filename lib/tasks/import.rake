namespace :import do
  require './config/genders'

  desc 'import users from slack to game'
  task import_players: :environment do
    ActiveRecord::Base.logger.level = 1
    puts '-> importing players'
    slack = Slack::Client.new
    unknown_genders = {}
    slack.users_list['members'].each do |member|
      begin
        membername = member['name']
        player_gender = Guess.gender(member['real_name'])[:gender]
        player_gender = Genders::GENDER_LIST[member['name']] if player_gender == 'unknown'
        if player_gender == 'unknown'
          unknown_genders[membername] = player_gender
          player_gender = 'male'
        end
        Player.create_player_by_slack_info(member['id'], membername, player_gender)
      rescue
        puts 'member already existed for ' + member['name']
      end
    end
    puts 'import complete. unknown genders: '
    puts unknown_genders.to_s
  end

  desc 'import rooms from slack to game'
  task import_rooms: :environment do
    ActiveRecord::Base.logger.level = 1
    puts 'importing rooms'
    slack = Slack::Client.new
    slack.channels_list['channels'].each do |channel|
      begin
        puts 'importing ' + channel['name']
        Room.create_room_from_channel(channel)
      rescue
        puts 'room already exists for room ' + channel['name']
      end
    end
  end

  desc 'add players to rooms'
  task add_players_to_rooms: :environment do
    ActiveRecord::Base.logger.level = 1
    puts '-> adding players to rooms'
    slack = Slack::Client.new
    slack.channels_list['channels'].each do |channel|
      begin
        puts "adding player to room #{channel['name']}"
        room = Room.where(slackid: channel['id']).first
        players = Player.where(slackid: channel['members'])
        room.update!(players: players)
        puts "added #{players.map(&:name)} to room #{room[:title]}"
      rescue => e
        puts "something went wrong when adding players to room #{room[:title]}"
        puts e
      end
    end
  end

  desc 'adds default properties to game'
  task add_default_properties_to_game: :environment do
    default_effects = [:effect_flying,
                       :effect_glowing,
                       :effect_invized,
                       :effect_pulsating,
                       :effect_poisoned]
    default_effects.each do |effect|
      puts "importing #{effect}"
      begin
        FactoryGirl.create(effect)
      rescue => e
        puts "error while adding effect: #{effect}, #{e}"
      end
    end
  end

  desc 'adds default items to game'
  task add_items_to_game: :environment do
    ActiveRecord::Base.logger.level = 1
    puts '-> adding default items'
    default_items = [:item_wizardhat,
                     :item_loaf,
                     :item_fedora,
                     :item_sculpin,
                     :item_magichat,
                     :item_cloak,
                     :item_klondike,
                     :item_tunic,
                     :item_dragonbone_dice,
                     :item_steel_dice,
                     :item_apple,
                     :item_loincloth,
                     :item_birthday_cake]
    default_items.each do |item|
      puts "importing #{item}"
      begin
        FactoryGirl.create(item)
      rescue => e
        puts "error while adding item : #{item}, #{e}"
      end
    end
  end

  desc 'import world'
  task import_world: :environment do
    begin
      ActiveRecord::Base.logger.level = 1
      Rake::Task['import:import_players'].invoke
      Rake::Task['import:import_rooms'].invoke
      Rake::Task['import:add_players_to_rooms'].invoke
      Rake::Task['import:add_items_to_game'].invoke
    rescue => e
      puts 'something went horribly wrong!'
      puts e
    end
    puts 'import complete!'
  end
end
