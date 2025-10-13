# typed: false
# frozen_string_literal: true

class AdminController < ApplicationController
  layout "admin"

  before_action :require_admin

  private

  def require_admin
    unless current_user&.admin?
      redirect_to decks_path, notice: "Acesso não autorizado"
    end
  end
end
