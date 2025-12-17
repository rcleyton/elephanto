# typed: false
# frozen_string_literal: true

class ErrorsController < ApplicationController
  allow_unauthenticated_access only: %i[ not_found internal_server_error ]
  layout "errors"

  def not_found
    if request.subdomain == "app" || request.host&.start_with?("app.")
      render "errors/app_not_found", status: :not_found
    else
      render "errors/public_not_found", status: :not_found
    end
  end

  def internal_server_error
    if request.subdomain == "app" || request.host&.start_with?("app.")
      render "errors/app_internal_server_error", status: :internal_server_error
    else
      render "errors/public_internal_server_error", status: :internal_server_error
    end
  end
end
