#!/usr/bin/env ruby
# encoding: utf-8

($LOAD_PATH << File.expand_path("..", __FILE__)).uniq!

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require 'bundle/bundler/setup'
require 'alfred'
require 'json'
require 'rest_client'
require 'yaml'

@api_key    = '1567f19970db62213b78fe1482cff991'
@user_token = ENV['TRELLO_USER_TOKEN']

@my_cards_url  = "https://api.trello.com/1/members/me/cards"
@my_boards_url = "https://api.trello.com/1/members/me/boards"

def load_config
  config_file_path = File.expand_path("~/.alfred-my-trello-cards.yml")
  return unless File.exists?(config_file_path)
  config = YAML.load_file(config_file_path)
  @user_token ||= config["user_token"]
end

def my_cards
  response = RestClient.get @my_cards_url, params: {
    key: @api_key,
    token: @user_token,
    fields: 'idShort,name,shortUrl,idBoard,desc',
    limit: 5
  }

  JSON.parse(response)
end

def my_boards
  @boards ||=
    begin
      response = RestClient.get @my_boards_url, params: {
        key: @api_key,
        token: @user_token,
        fields: 'id,name'
      }

      json = JSON.parse(response)
      json.each_with_object(Hash.new(0)) { |board, hash| hash[board['id']] = board['name'] }
    end
end

def card_json_to_alfred(card)
  idShort, name, desc, board_id = [ card['idShort'], card['name'], card['desc'].to_s, card['idBoard'] ]

  subtitle = my_boards[board_id]
  subtitle += ' - ' + desc.gsub("\n", "; ").slice(0, 100) unless desc.empty?

  {
    title: "##{ idShort } - #{ name }",
    subtitle: subtitle,
    arg: card['shortUrl']
  }
end

Alfred.with_friendly_error do |alfred|
  alfred.with_rescue_feedback = true

  load_config

  fb = alfred.feedback
  my_cards.each { |card| fb.add_item(card_json_to_alfred(card)) }
  puts fb.to_alfred
end
