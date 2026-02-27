# typed: false
# frozen_string_literal: true

module ApplicationHelper
  def flash_class_for(type)
    {
      notice:  "bg-blue-600 text-white",
      alert:   "bg-yellow-500 text-gray-900",
      error:   "bg-red-500 text-white",
      success: "bg-green-600 text-white"
    }.fetch(type.to_sym)
  end

  def path_to_profile
    profile = current_user.profile
    profile&.id.present? ? profile_path(profile) : new_profile_path
  end

  def flashcard_progress(deck)
    queue      = session[:review_queue] || []
    total      = session[:total_review] || queue.size
    completed  = total - queue.size
    current    = completed + 1

    percent = total.positive? ? ((completed.to_f / total) * 100).round : 0

    {
      current: current,
      completed: completed,
      total: total,
      percent: percent
    }
  end

  def app_root_url
    if Rails.env.production?
      "https://app.getelephanto.com"
    else
      "http://app.localhost:4000"
    end
  end

  def seconds_to_str(seconds)
    [ "#{seconds/3600}h", "#{seconds/60%60}m", "#{seconds%60}s" ]
      .select { |str| str =~ /[1-9]/ }.join(" ")
  end

  def page_header(options = {})
    HeaderPresenter.new(self, options).render
  end

  def input_error?(model, field)
    model.errors[field].any?
  end

  def error_class(model, field)
    input_error?(model, field) ? "ui-input-error" : ""
  end
end
