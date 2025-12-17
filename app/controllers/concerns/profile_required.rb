# typed: false
# frozen_string_literal: true

module ProfileRequired
  extend ActiveSupport::Concern

  private

  def required_profile
    unless current_user.profile.present?
      redirect_to new_profile_path, alert: t("messages.missing_profile")
    end
  end
end
