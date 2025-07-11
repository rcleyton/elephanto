# typed: false
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def render_not_found
    flash[:alert] = t("messages.render_not_found")
    redirect_to decks_path
  end
end
