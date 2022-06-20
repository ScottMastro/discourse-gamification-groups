# frozen_string_literal: true

class GroupScoreSerializer < ApplicationSerializer
    attributes  :id,
                :name,
                :flair_url,
                :flair_color,
                :flair_bg_color,
                :user_count,
                :total_score
  end
  