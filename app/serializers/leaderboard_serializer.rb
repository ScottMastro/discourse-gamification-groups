# frozen_string_literal: true

class LeaderboardSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :created_by_id,
             :from_date,
             :to_date,
             :visible_to_groups_ids,
             :included_groups_ids,
             :is_group_leaderboard,
             :updated_at
end
