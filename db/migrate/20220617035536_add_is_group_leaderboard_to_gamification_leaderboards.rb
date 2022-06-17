class AddIsGroupLeaderboardToGamificationLeaderboards < ActiveRecord::Migration[6.1]
  def change
    add_column :gamification_leaderboards, :is_group_leaderboard, :boolean, null: false, default: false
  end
end
