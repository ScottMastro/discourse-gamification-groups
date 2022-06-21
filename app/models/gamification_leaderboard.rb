# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboard < ::ActiveRecord::Base
  PAGE_SIZE = 100

  self.table_name = 'gamification_leaderboards'
  validates :name, exclusion: { in: %w(new),
                                message: "%{value} is reserved." }

  def self.scores_for(leaderboard_id, page: 0, for_user_id: false)
    leaderboard = self.find(leaderboard_id)
    leaderboard.to_date ||= Date.today

    join_sql = "LEFT OUTER JOIN gamification_scores ON gamification_scores.user_id = users.id"
    sum_sql = "SUM(COALESCE(gamification_scores.score, 0)) as total_score"

    users = User.joins(:primary_email).real.where.not("user_emails.email LIKE '%@anonymized.invalid%'").where(staged: false).joins(join_sql)
    users = users.joins(:groups).where(groups: { id: leaderboard.included_groups_ids }) if leaderboard.included_groups_ids.present?
    users = users.where("gamification_scores.date BETWEEN ? AND ?", leaderboard.from_date, leaderboard.to_date) if leaderboard.from_date.present?
    # calculate scores up to to_date if just to_date is present
    users = users.where("gamification_scores.date <= ?", leaderboard.to_date) if leaderboard.to_date != Date.today && !leaderboard.from_date.present?
    users = users.select("users.id, users.username, users.uploaded_avatar_id, #{sum_sql}").group("users.id").order(total_score: :desc, id: :asc)
    if for_user_id
      user = users.find_by(id: for_user_id)
      index = users.index(user)
      return { user: user, position: index ? index + 1 : nil }
    end
    users = users.offset(PAGE_SIZE * page) if page > 0
    users = users.limit(PAGE_SIZE)

    users
  end

  def self.group_scores_for(leaderboard_id)
    leaderboard = self.find(leaderboard_id)
    leaderboard.to_date ||= Date.today
    
    join_sql = "LEFT OUTER JOIN gamification_scores ON gamification_scores.user_id = users.id"
    join_sql2 = "LEFT OUTER JOIN uploads ON uploads.id = groups.flair_upload_id"

    sum_sql = "SUM(COALESCE(gamification_scores.score, 0)) as total_score"

    users = User.joins(:primary_email).real.where.not("user_emails.email LIKE '%@anonymized.invalid%'").where(staged: false).joins(join_sql)
    users = users.joins(:groups).where(groups: { id: leaderboard.included_groups_ids }) if leaderboard.included_groups_ids.present?
    users = users.where("gamification_scores.date BETWEEN ? AND ?", leaderboard.from_date, leaderboard.to_date) if leaderboard.from_date.present?
    # calculate scores up to to_date if just to_date is present
    users = users.where("gamification_scores.date <= ?", leaderboard.to_date) if leaderboard.to_date != Date.today && !leaderboard.from_date.present?
    users = users.joins(join_sql2)
    groups = users.select("groups.id as id, groups.name as name, uploads.url as flair_url, groups.flair_color, groups.flair_bg_color, groups.user_count, #{sum_sql}").group("groups.id", "uploads.id")
    
    groups
  end
end
