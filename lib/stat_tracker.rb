require './spec/spec_helper'

class StatTracker
  attr_reader :all_data, :games, :game_teams, :teams
  
  def initialize(all_data)
    @all_data = all_data
    @games = []
    @game_teams = []
    @teams = []
    create_games
    create_game_teams
    create_teams
  end

  def self.from_csv(locations)
    all_data = {}
    locations.each do |file_name, location|
      formatted_csv = CSV.open location, headers: true, header_converters: :symbol
      all_data[file_name] = formatted_csv
    end
    StatTracker.new(all_data)
  end

  def highest_total_score
    total_goals_by_game_id.values.max
  end

  def lowest_total_score
    total_goals_by_game_id.values.min
  end

  def percentage_home_wins
    number_of_games = game_ids.length
    games_won = 0
    @game_teams.each do |game|
      if game.hoa == 'home' && game.result == 'WIN'
        games_won += 1
      end
    end
    percentage = (games_won.to_f / number_of_games.to_f).round(2)
  end
  
  def percentage_visitor_wins
    number_of_games = game_ids.length
    games_won = 0
    @game_teams.each do |game|
      if game.hoa == 'away' && game.result == 'WIN'
        games_won += 1
      end
    end
    percentage = (games_won.to_f / number_of_games.to_f).round(2)
  end

  def percentage_ties   
    number_of_games = game_ids.length
    games_tied = 0
    @game_teams.each do |game|
      if game.hoa == 'away' && game.result == 'TIE'
        games_tied += 1
      end
    end
    percentage = (games_tied.to_f / number_of_games.to_f).round(2)
  end

  def count_of_games_by_season
  count_games = {}
    @games.each do |game|
      if count_games[game.season].nil? # Added [1] to continue method with adjustment to games_list
        count_games[game.season] = 1
      else
        count_games[game.season] += 1
      end
    end
    count_games
  end

  def average_goals_per_game
    game_count = game_ids.count.to_f
    average_goals_per_game = total_goals_by_game_id.values.sum.to_f / game_count
    average_goals_per_game.round(2)
  end

  def average_goals_by_season
    average_goals_by_season = total_scores_by_season.map { |season, total_scores| [season, (total_scores.to_f/count_of_games_by_season[season].to_f).round(2)]}.to_h
  end

  def count_of_teams
    @teams.count
  end

  def best_offense
    max_team_id = avg_team_goals_league.max_by { |team_id, avg| avg }[0]
    best_team = @teams.find do |team|
      team.team_id == max_team_id
    end
    best_team.team_name
  end

  def worst_offense
    min_team_id = avg_team_goals_league.min_by { |team_id, avg| avg }[0]
    worst_team = @teams.find do |team|
      team.team_id == min_team_id
    end
    worst_team.team_name
  end

  def highest_scoring_visitor
    team_goals = Hash.new(0)
    @game_teams.each do |game_team, goals|
      if game_team.hoa == 'away' && !team_goals.include?(game_team.team_id)
        team_goals[game_team.team_id] = [game_team.goals.to_f]
      elsif game_team.hoa == 'away' && team_goals.include?(game_team.team_id)
        team_goals[game_team.team_id] << game_team.goals.to_f
      end
    end
    max_team(team_goals)
  end

  def highest_scoring_home_team
    team_goals = Hash.new(0)
    @game_teams.each do |game_team, goals|
      if game_team.hoa == 'home' && !team_goals.include?(game_team.team_id)
        team_goals[game_team.team_id] = [game_team.goals.to_f]
      elsif game_team.hoa == 'home' && team_goals.include?(game_team.team_id)
        team_goals[game_team.team_id] << game_team.goals.to_f
      end
    end
    max_team(team_goals)
  end
  
  def lowest_scoring_visitor
    team_goals = Hash.new(0)
    @game_teams.each do |game_team, goals|
      if game_team.hoa == 'away' && !team_goals.include?(game_team.team_id)
        team_goals[game_team.team_id] = [game_team.goals.to_f]
      elsif game_team.hoa == 'away' && team_goals.include?(game_team.team_id)
        team_goals[game_team.team_id] << game_team.goals.to_f
      end
    end
    min_team(team_goals)
  end

  def lowest_scoring_home_team
    team_goals = Hash.new(0)
    @game_teams.each do |game_team, goals|
      if game_team.hoa == 'home' && !team_goals.include?(game_team.team_id)
        team_goals[game_team.team_id] = [game_team.goals.to_f]
      elsif game_team.hoa == 'home' && team_goals.include?(game_team.team_id)
        team_goals[game_team.team_id] << game_team.goals.to_f
      end
    end
    min_team(team_goals)
  end

  def winningest_coach(season)
    season_comparer = season[0..3]
    winning_games_in_season = @game_teams.find_all do |game_team| 
      game_id_comparer = game_team.game_id[0..3]
      game_team.result == "WIN" && season_comparer == game_id_comparer
    end
    coach_count = {}
    winning_games_in_season.each do |game|
      if coach_count[game.head_coach].nil? 
        coach_count[game.head_coach] = 1
      else 
        coach_count[game.head_coach] += 1
      end
    end 
    coach_count.max_by{ |k,v| v }.first
  end

  def worst_coach(season) 
    season_comparer = season[0..3]
    losing_games_in_season = @game_teams.find_all do |game_team| 
      game_id_comparer = game_team.game_id[0..3]
      game_team.result == "WIN" && season_comparer == game_id_comparer
    end
    coach_count = {}
    losing_games_in_season.each do |game|
      if coach_count[game.head_coach].nil? 
        coach_count[game.head_coach] = 1
      else 
        coach_count[game.head_coach] += 1
      end
    end 
    coach_count.min_by{ |k,v| v }.first
  end

  def most_accurate_team(season)
    season_comparer = season[0..3]
    games_in_season = @game_teams.find_all do |game_team| 
      game_id_comparer = game_team.game_id[0..3]
      season_comparer == game_id_comparer
    end
    team_comparison = {}
    games_in_season.each do |game|
      if team_comparison[game.team_id].nil?
        team_comparison[game.team_id]= [(game.goals/game.shots).round(2)]
      else
        team_comparison[game.team_id] << (game.goals/game.shots).round(2)
      end
    end
    team_comparison = team_comparison.map{|team_id, ratio_array| [team_id, (ratio_array.sum/ratio_array.length).round(2)]}.to_h
    most_accurate_teamid = team_comparison.sort_by { |k,v| -v }.first.first
    most_accurate_team_name = @teams.find { |team| team.team_id == most_accurate_teamid }.team_name
  end

  def least_accurate_team(season)
    season_comparer = season[0..3]
    games_in_season = @game_teams.find_all do |game_team| 
      game_id_comparer = game_team.game_id[0..3]
      season_comparer == game_id_comparer
    end
    team_comparison = {}
    games_in_season.each do |game|
      if team_comparison[game.team_id].nil?
        team_comparison[game.team_id] = [(game.goals/game.shots).round(2)]
      else
        team_comparison[game.team_id] << (game.goals/game.shots).round(2)
      end
    end
    team_comparison = team_comparison.map { |team_id, ratio_array| [team_id, (ratio_array.sum/ratio_array.length).round(2)] }.to_h
    least_accurate_teamid = team_comparison.sort_by { |k,v| v }.first.first
    least_accurate_team_name = @teams.find { |team| team.team_id == least_accurate_teamid }.team_name
  end

  def most_tackles(season)
    max_team_id = team_season_tackles(season).max_by { |team_id, tackles| tackles }[0]
    best_team = @teams.find { |team| team.team_id == max_team_id }
    best_team.team_name
  end

  def fewest_tackles(season)
    min_team_id = team_season_tackles(season).min_by { |team_id, tackles| tackles }[0]
    worst_team = @teams.find { |team| team.team_id == min_team_id }
    worst_team.team_name
  end

  def game_team_ids
    team_ids = @game_teams.map { |game| game.team_id }.uniq
  end
  
  def game_ids
    @game_teams.map{ |game| game.game_id }.uniq
  end

  ## Takes in a team id and returns team name
  def team_name(found_id)
    found_team = @teams.find { |team| team.team_id == found_id }
    found_team.team_name
  end

  ## Finds the max average score by game id
  def max_team(team_goals)
    team_averages = {}
    team_goals.each do |team_goal, value|
      team_averages[team_goal] = (value.sum / value.length.to_f)
    end
    max_id = team_averages.max_by { |k,v| v }.first
    team_name(max_id)
  end

  ## Finds the min average score by game id
  def min_team(team_goals)
    team_averages = {}
    team_goals.each do |team_goal, value|
      team_averages[team_goal] = (value.sum / value.length.to_f)
    end
    min_id = team_averages.min_by { |k,v| v }.first
    team_name(min_id)
  end
  
  def team_games_league_total
    @teams.reduce(Hash.new(0)) do |team_games_total, team|
      @games.each do |game|
        if team.team_id == game.home_team_id || team.team_id == game.away_team_id
          team_games_total[team.team_id] += 1 
        end
      end
      team_games_total
    end
  end
  
  def team_goals_league_total
    @teams.reduce(Hash.new(0)) do |team_goals_total, team|
      @games.each do |game|
        if team.team_id == game.home_team_id
          team_goals_total[team.team_id] += game.home_goals
        elsif team.team_id == game.away_team_id
          team_goals_total[team.team_id] += game.away_goals
        end
      end
      team_goals_total
    end
  end

  def avg_team_goals_league
    team_avgs = Hash.new
    game_team_ids.each do |team|
      team_games = team_games_league_total[team]
      team_goals = team_goals_league_total[team]
      goal_stat = (team_goals.to_f / team_games).round(2)
      team_avgs[team] = goal_stat
    end
    team_avgs
  end

  def create_teams
    @all_data[:teams].each do |row|
      team = Team.new(row[:team_id], row[:teamname])
      @teams << team
    end
    @teams
  end

  def create_games
    @all_data[:games].each do |row|
      game = Game.new(row[:game_id],
                      row[:season],
                      row[:away_goals],
                      row[:home_goals], 
                      row[:away_team_id], 
                      row[:home_team_id] 
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
                      row[:result],
                      row[:tackles],
                      row[:head_coach],
                      row[:shots]
                      )
      @game_teams << game_team
    end
    @game_teams
  end

  ##Returns a hash of game ID for key and total goals as value
  def total_goals_by_game_id
    total_goals_by_game_id = {}
    game_ids.each do |game_id|
      total_goals_by_game_id[game_id] = 0
    end
    @game_teams.each do |game|
      total_goals_by_game_id[game.game_id] += game.goals.to_i
    end
    total_goals_by_game_id
  end

  # Returns a hash of season as key and total scores of all games in that season for value
  def total_scores_by_season
    total_scores_by_season = {}
    @games.each do |game|
      if total_scores_by_season[game.season].nil? # Added [1] to continue method with adjustment to games_list
        total_scores_by_season[game.season] = 0
      end
      total_scores_by_season[game.season] += (game.away_goals + game.home_goals)
    end
    total_scores_by_season
  end

  def team_season_tackles(season)
    season_comparer = season[0..3]
    game_team_ids.reduce(Hash.new(0)) do |team_tackles, team_id|
      @game_teams.each do |game|
        game_id_comparer = game.game_id[0..3]
        if team_id == game.team_id && season_comparer == game_id_comparer
          team_tackles[team_id] += game.tackles
        end
      end
      team_tackles
    end
  end

end