# typed: false
# frozen_string_literal: true

module ApplicationHelper
  def flash_class_for(type)
    {
      notice: "bg-blue-100 text-blue-800 border-blue-300",
      alert: "bg-yellow-100 text-yellow-800 border-yellow-300",
      error: "bg-red-100 text-red-800 border-red-300",
      success: "bg-green-100 text-green-800 border-green-300"
    }.fetch(type.to_sym, "bg-gray-100 text-gray-800 border-gray-300")
  end

def path_to_profile
  profile = current_user.profile
  profile&.id.present? ? profile_path(profile) : new_profile_path
end
end
