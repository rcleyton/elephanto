class ReviewSession < ApplicationRecord
  belongs_to :user
  belongs_to :deck

  scope :total_review_sessions, ->(id) { where(user_id: id) }

  def progress_percentage
    return 0 if total_count.zero?
    ((reviewed_count.to_f / total_count) * 100).round
  end

  def complete?
    reviewed_count >= total_count
  end

  def completed_at?
    completed_at.present?
  end
end
