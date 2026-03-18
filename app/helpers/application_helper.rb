# typed: false
# frozen_string_literal: true

module ApplicationHelper
  def flash_class_for(type)
    {
      notice:  "border-indigo-100 bg-white/90 dark:bg-slate-900/90 text-indigo-600 dark:text-indigo-400 shadow-indigo-500/10",
      alert:   "border-amber-100 bg-white/90 dark:bg-slate-900/90 text-amber-600 dark:text-amber-400 shadow-amber-500/10",
      error:   "border-red-100 bg-white/90 dark:bg-slate-900/90 text-red-600 dark:text-red-400 shadow-red-500/10",
      success: "border-emerald-100 bg-white/90 dark:bg-slate-900/90 text-[#60c2a6] dark:text-emerald-400 shadow-emerald-500/10"
    }.fetch(type.to_sym, "border-slate-100 bg-white/90 text-slate-600")
  end

  def flash_icon_for(type)
    {
      notice:  "info",
      alert:   "warning",
      error:   "dangerous",
      success: "check_circle"
    }.fetch(type.to_sym, "notifications")
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
    input_error?(model, field) ? "input-error" : ""
  end

  def format_fsrs_interval(card_options)
    due             = card_options.due
    now             = Time.current.utc
    diff_in_seconds = (due - now).to_i

    if diff_in_seconds < 60
      "agora"
    elsif diff_in_seconds < 3600
      "#{diff_in_seconds / 60} min"
    elsif diff_in_seconds < 86400
      "#{diff_in_seconds / 3600} h"
    else
      days = card_options.scheduled_days
      days >= 30 ? "#{(days / 30.0).round(1)} mes" : "#{days} d"
    end
  end

  def fsrs_state_badge(flashcard)
    state = flashcard.fsrs_card.state

    label, classes =
      case state
      when 0
        [ "Novo", "bg-slate-100 dark:bg-slate-800 text-slate-500" ]
      when 1
        [ "Aprendendo", "bg-amber-500/10 text-amber-600" ]
      when 2
        [ "Aprendido", "bg-emerald-100 text-emerald-700" ]
      else
        [ "Esquecido", "bg-rose-100 text-rose-700" ]
      end

    content_tag(:span, label,
      class: "
        px-2 py-1 rounded
        #{classes}
        text-[10px] font-bold uppercase tracking-wider
      "
    )
  end
end
