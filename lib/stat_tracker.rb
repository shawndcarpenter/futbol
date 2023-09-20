class StatTracker

  attr_reader :all_data, :games, :game_teams, :teams, :game_ids
  
  def initialize(all_data)
    @all_data = all_data
    @games = []
    @game_teams = []
    @teams = []
    @game_ids = []
  end

  def self.from_csv(locations)
    all_data = {}
    locations.each do |file_name, location|
      formatted_csv = CSV.open location, headers: true, header_converters: :symbol
      all_data[file_name] = formatted_csv
    end
    StatTracker.new(all_data)
  end

  ## Creates game objects from the CSV file
  def create_games
    @all_data[:games].each do |row|
      game = Game.new(row[:game_id],
                      row[:season],
                      row[:away_goals],
                      row[:home_goals], 
                      )
      @games << game
    end
    @games
  end

  def create_game_teams
    @all_data[:game_teams].each do |row|
      game_team = GameTeam.new(row[:game_id],
                      row[:team_id],
                      row[:goals], 
                      row[:hoa], 
                      row[:result]
                      )
      @game_teams << game_team
    end
    @game_teams
  end

  ## Returns highest total score of added scores of that game (INTEGER)
  def highest_total_score
    games_hash = {}
    game_ids.each do |game_id|
      games_hash[game_id]=0
    end
    @game_teams.each do |game|
      games_hash[game.game_id]+=game.goals.to_i
    end
    games_hash.values.max
  end

  ## Returns lowest total score of added scores of that game (INTEGER)
  def lowest_total_score
    games_hash = {}
    games_hash = {}
    game_ids.each do |game_id|
      games_hash[game_id]=0
    end
    @game_teams.each do |game|
      games_hash[game.game_id]+=game.goals.to_i
    end
    games_hash.values.min
  end

  ## A hash with season names (e.g. 20122013) as keys and counts of games as values
  def count_of_games_by_season
  count_games = {}
   @games.each do |game|
    if count_games[game.season].nil? # Added [1] to continue method with adjustment to games_list
      count_games[game.season] = 0
    else
      count_games[game.season] +=1
    end
   end
   count_games
  end

  def percentage_home_wins
    # Percentage of games that a home team has won (rounded to the nearest 100th)
    #find total number of games
    number_of_games = game_ids.length
    #find when home/away is home and result is win
    games_won = 0
    @game_teams.each do |game|
      if game.hoa == 'home' && game.result == 'WIN'
        games_won += 1
      end
    end
    percentage = (games_won.to_f / number_of_games.to_f * 100).round(2)
  end
  
  def percentage_visitor_wins
    ## Percentage of games that a visitor has won (rounded to the nearest 100th)
    ##find total number of games
    number_of_games = game_ids.length
    ##find when home/away is away and result is win
    games_won = 0
    @game_teams.each do |game|
      if game.hoa == 'away' && game.result == 'WIN'
        games_won += 1
      end
    end
    percentage = (games_won.to_f / number_of_games.to_f * 100).round(2)
  end

  def percentage_ties   
    # Percentage of games that has resulted in a tie (rounded to the nearest 100th)
    #total number of games
    number_of_games = game_ids.length
    #result is tie
    games_tied = 0
    @game_teams.each do |game|
      if game.hoa == 'away' && game.result == 'TIE'
        games_tied += 1
      end
    end
    percentage = (games_tied.to_f / number_of_games.to_f * 100).round(2)
  end

  ##HELPER METHODS
    ## Creates an array of game_ids, acts as helper method
    def game_ids
      @game_ids = @game_teams.map{|game| game.game_id}.uniq
    end
end
