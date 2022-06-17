# frozen_string_literal: true

class LeaderboardViewSerializer < ApplicationSerializer
  has_one :leaderboard, serializer: LeaderboardSerializer, embed: :objects
  has_many :users, serializer: UserScoreSerializer, embed: :objects
  has_many :groups, serializer: GroupScoreSerializer, embed: :objects

  def leaderboard
    object[:leaderboard]
  end

  def users
    DiscourseGamification::GamificationLeaderboard.scores_for(object[:leaderboard].id, object[:page])
  end

  def groups
    DiscourseGamification::GamificationLeaderboard.group_scores_for(object[:leaderboard].id)
  end
end
