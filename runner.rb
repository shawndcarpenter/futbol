require './spec/spec_helper'

game_teams_path = 'data/game_teams.csv'
game_path =       'data/games.csv'
team_path =       'data/teams.csv'
locations = { game_teams: game_teams_path, 
              games: game_path, 
              teams: team_path,
            }

stats = StatTracker.from_csv(locations)
puts "\n~~~Game Statistics~~~\n\n"
puts "The highest total score of all games is: #{stats.highest_total_score}"
puts "The percentage of home wins is: #{(stats.percentage_home_wins*100)}%"
puts "The average goals per game is:"
stats.count_of_games_by_season.each{|key, value| puts "Game ID: " + key + " Average Goals: " + value.to_s}

puts "\n~~~Season Statistics~~~\n"
puts "\nThe most successful coach in 2012 is: #{stats.winningest_coach('20122013')}"
puts "The most accurate team in 2012 is: #{stats.most_accurate_team('20122013')}"
puts "The team with most tackles in 2012 is: #{stats.most_tackles('20122013')}"

puts "\n~~~League Statistics~~~\n\n"
puts "The team with best offense in the league is: #{stats.best_offense}"
puts "The highest scoring visiting team in the league is: #{stats.highest_scoring_visitor}"
puts "The lowest scoring home team in the league is: #{stats.lowest_scoring_home_team}\n "