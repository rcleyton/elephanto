class ReviewSession < ApplicationRecord
  belongs_to :user
  belongs_to :deck

  def progress_percentage
    return 0 if total_count.zero?
    ((reviewed_count.to_f / total_count) * 100).round
  end

  def complete?
    reviewed_count >= total_count
  end
end
