require './spec/spec_helper'

RSpec.describe StatTracker do
  before(:each) do
    ## LOCATING CSV FILES
    game_teams_path = './data/game_team_fixture.csv'
    game_path = './data/games_fixture.csv'
    team_path = './data/teams.csv'
    @locations = {  game_teams: game_teams_path, 
                    games: game_path, 
                    teams: team_path,
                  }

    @stats = StatTracker.from_csv(@locations)
  end
  
  describe '#initialize' do
    it 'exists' do
      expect(@stats).to be_instance_of(StatTracker)
    end
    
    it 'has attributes' do
      expect(@stats.all_data.values.all? { |file| File.exist?(file) } ).to be true
    end

    it 'makes using #create_teams, #create_games, and #create_game_teams' do
      expect(@stats.instance_variable_get(:@teams)).to all be_a Team
      expect(@stats.instance_variable_get(:@games)).to all be_a Game
      expect(@stats.instance_variable_get(:@game_teams)).to all be_a GameTeam
    end
  end

  describe '::from_csv' do
    it 'Gets data and makes instance' do
      expect(StatTracker.from_csv(@locations)).to be_instance_of(StatTracker)
    end
  end
  
  describe '#GameStatistics' do
    it 'list of gets goals for a game' do
      expect(@stats.total_goals_by_game_id.class).to be Hash
      expect(@stats.total_goals_by_game_id['2012030222']).to eq(5)
    end
    
    it 'gets highest total score' do
      expect(@stats.highest_total_score).to eq(7)
    end

    it 'gets the lowest total score' do
      expect(@stats.lowest_total_score).to eq(1)
    end

    it 'returns a hash of season names as keys and counts of games as values' do
      expect(@stats.count_of_games_by_season.class).to be Hash
      expect(@stats.count_of_games_by_season).to eq({ "20122013"=>19, 
                                                      "20152016"=>33, 
                                                      "20162017"=>36, 
                                                      "20172018"=>35})
    end

    it 'returns list of game_ids' do
      expect(@stats.game_ids[0]).to eq("2012030221")
      expect(@stats.game_ids.all? { |id| id.class == String }).to eq(true)
    end

    it 'returns percentage of games home team won' do
      expect(@stats.percentage_home_wins).to be_a Float      
    end
     
    it 'returns percentage of games visitor team won' do
      expect(@stats.percentage_visitor_wins).to be_a Float
    end
    
    it 'returns percentage of games resulting in a tie' do
      expect(@stats.percentage_ties).to be_a Float
    end

    it 'rounds to 100 percent' do
      expect((@stats.percentage_ties + @stats.percentage_home_wins + @stats.percentage_visitor_wins).round).to eq(1)
    end

    it 'returns average number of goals scored in a game across all seasons' do
      expect(@stats.average_goals_per_game.class).to be Float
      expect(@stats.average_goals_per_game).to eq(3.91)
    end

    it 'gets list of total scores by a season' do
      expect(@stats.total_scores_by_season.class).to be Hash
      expect(@stats.total_scores_by_season).to eq({"20122013"=>70, "20152016"=>140, "20162017"=>163, "20172018"=>154})
    end

    it 'returns average number of goals scored in a game' do
      expect(@stats.average_goals_by_season.class).to be Hash
      expect(@stats.average_goals_by_season).to eq({"20122013"=>3.68, "20152016"=>4.24, "20162017"=>4.53, "20172018"=>4.40})
    end
  end

  describe '#count_of_teams' do
    it 'gets total number of teams in league' do
      expect(@stats.count_of_teams).to eq(32)
    end
  end

  describe '#best_offense, #worst_offense' do
    it 'gets game_teams list' do
      expect(@stats.game_team_ids).to eq(['3', '6', '5', '28', '19', '8', '9'])
    end

    it 'gets number games each team played in all seasons' do
      expect(@stats.team_games_league_total.class).to be Hash
      expect(@stats.team_games_league_total['3']).to eq(10)
    end

    it 'gets number games each team played in all seasons' do
      expect(@stats.team_goals_league_total.class).to be Hash
      expect(@stats.team_goals_league_total['3']).to eq(22)
    end

    it 'team goal average per game in all seasons' do
      expect(@stats.avg_team_goals_league.class).to be Hash
      expect(@stats.avg_team_goals_league['3']).to eq(2.2)
    end

    it 'returns team(s) with highest avg goals per game' do
      expect(@stats.best_offense).to eq('FC Dallas')
    end

    it 'returns team(s) with lowest avg goals per game' do
      expect(@stats.worst_offense).to eq('Sporting Kansas City')
    end
  end

  describe '#highest_scoring and #lowest_scoring' do
    it 'finds the name of team with lowest average score' do
      expect(@stats.max_team({"6"=>[3.0], "3"=>[1.0], "5"=>[0.0],})).to eq("FC Dallas")
    end

    it 'finds the name of team with lowest average score' do
      expect(@stats.min_team({"3"=>[2.0],"6"=>[3.0],"5"=>[1.0],})).to eq("Sporting Kansas City")
    end

    it 'finds the name of a team from a team id' do
      expect(@stats.team_name("1")).to eq("Atlanta United")
    end

    it 'returns name of team with highest average when away' do
      expect(@stats.highest_scoring_visitor.class).to be String
      expect(@stats.highest_scoring_visitor).to eq('New York Red Bulls')
    end
    
    it 'returns name of team with highest average when home' do
      expect(@stats.highest_scoring_home_team.class).to be String
      expect(@stats.highest_scoring_home_team).to eq('Los Angeles FC')
    end

    it 'returns name of team with lowest average when away' do
      expect(@stats.lowest_scoring_visitor.class).to be String
      expect(@stats.lowest_scoring_visitor).to eq('Sporting Kansas City')
    end

    it 'returns name of team with lowest average when home' do
      expect(@stats.lowest_scoring_home_team.class).to be String
      expect(@stats.lowest_scoring_home_team).to eq('Sporting Kansas City')
    end
  end
  
  describe "#winningest_coach and #worst_coach" do
    it 'returns name of the Coach with the best win percentage for the season' do 
      expect(@stats.winningest_coach('20122013').class).to be String
      expect(@stats.winningest_coach('20122013')).to eq("Claude Julien")
    end

    it 'returns name of the Coach with the worst win percentage for the season' do
      expect(@stats.worst_coach('20152016')).to eq("Ken Hitchcock")
    end
  end

  describe '#most_accurate_team and #least_accurate_team' do
    it 'can return the most accurate team of the season by name' do
      expect(@stats.most_accurate_team('20122013').class).to be String
      expect(@stats.most_accurate_team('20122013')).to eq("FC Dallas")
    end

    it 'can return the least accurate team of the season by name' do
      expect(@stats.least_accurate_team('20122013').class).to be String
      expect(@stats.least_accurate_team('20122013')).to eq("Sporting Kansas City")
    end
  end
  
  describe '#most_tackles, #fewest_tackles' do
    it 'list of teams who played in a season' do
      expect(@stats.game_team_ids).to eq(['3', '6', '5', '28', '19', '8', '9'])
    end

    it 'list of tackles for teams' do
      expect(@stats.team_season_tackles('20122013').class).to be Hash
      expect(@stats.team_season_tackles('20122013')['3']).to eq(179)
    end

    it '#gets team with most tackles in a season' do
      expect(@stats.most_tackles('20122013').class).to be String
      expect(@stats.most_tackles('20122013')).to eq('FC Dallas')
      expect(@stats.most_tackles('20132014')).to eq('FC Dallas')
    end

    it '#gets team with least tackles in a season' do
      expect(@stats.fewest_tackles('20122013').class).to be String
      expect(@stats.fewest_tackles('20122013')).to eq ('Sporting Kansas City')
      expect(@stats.fewest_tackles('20132014')).to eq ('New York Red Bulls')
    end
  end
end