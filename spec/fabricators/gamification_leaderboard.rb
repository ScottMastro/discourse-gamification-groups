# frozen_string_literal: true

Fabricator(:gamification_leaderboard, from: ::DiscourseGamification::GamificationLeaderboard) do
  name { sequence(:name) { |i| "leaderboard#{i + 1}" } }
  created_by_id { Fabricate(:user).id }
  from_date { nil }
  to_date { nil }
  visible_to_groups_ids { [] }
  included_groups_ids { [] }
  is_group_leaderboard { false }
end
