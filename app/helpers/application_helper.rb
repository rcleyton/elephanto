# typed: false
# frozen_string_literal: true

module ApplicationHelper
  def flash_class_for(type)
    {
      notice:  "bg-blue-600 text-white",
      alert:   "bg-yellow-500 text-gray-900",
      error:   "bg-red-500 text-white",
      success: "bg-green-600 text-white",
    }.fetch(type.to_sym)
  end

  def path_to_profile
    profile = current_user.profile
    profile&.id.present? ? profile_path(profile) : new_profile_path
  end
end
