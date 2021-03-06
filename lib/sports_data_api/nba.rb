module SportsDataApi
  module Nba

    class Exception < ::Exception
    end

    DIR = File.join(File.dirname(__FILE__), 'nba')
    BASE_URL = 'http://api.sportsdatallc.org/nba-%{access_level}%{version}'
    DEFAULT_VERSION = 3
    SPORT = :nba

    autoload :Team, File.join(DIR, 'team')
    autoload :Teams, File.join(DIR, 'teams')
    autoload :Player, File.join(DIR, 'player')
    autoload :Game, File.join(DIR, 'game')
    autoload :Games, File.join(DIR, 'games')
    autoload :Season, File.join(DIR, 'season')
    autoload :Venue, File.join(DIR, 'venue')
    autoload :Broadcast, File.join(DIR, 'broadcast')

    ##
    # Fetches NBA season schedule for a given year and season
    def self.schedule(year, season, version = DEFAULT_VERSION)
      season = season.to_s.upcase.to_sym
      raise SportsDataApi::Nba::Exception.new("#{season} is not a valid season") unless Season.valid?(season)

      response = self.response_xml(version, "/games/#{year}/#{season}/schedule.xml")

      return Season.new(response.xpath("/league/season-schedule"))
    end

    ##
    # Fetches NBA team roster
    def self.team_roster(team, version = DEFAULT_VERSION)
      response = self.response_xml(version, "/teams/#{team}/profile.xml")

      return Team.new(response.xpath("team"))
    end

    ##
    # Fetches NBA game summary for a given game
    def self.game_summary(game, version = DEFAULT_VERSION)
      response = self.response_xml(version, "/games/#{game}/summary.xml")

      return Game.new(xml: response.xpath("/game"))
    end

    ##
    # Fetches all NBA teams
    def self.teams(version = DEFAULT_VERSION)
      response = self.response_xml(version, "/league/hierarchy.xml")

      return Teams.new(response.xpath('/league'))
    end

    ##
    # Fetches NBA daily schedule for a given date
    def self.daily(year, month, day, version = DEFAULT_VERSION)
      response = self.response_xml(version, "/games/#{year}/#{month}/#{day}/schedule.xml")

      return Games.new(response.xpath('league/daily-schedule'))
    end

    private
    def self.response_xml(version, url)
      base_url = BASE_URL % { access_level: SportsDataApi.access_level(SPORT), version: version }
      response = SportsDataApi.generic_request("#{base_url}#{url}", SPORT)
      Nokogiri::XML(response.to_s).remove_namespaces!
    end
  end
end
