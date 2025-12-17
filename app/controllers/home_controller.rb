# typed: false
# frozen_string_literal: true

class HomeController < ApplicationController
  def redirect
    if current_user
      redirect_to decks_path
    else
      redirect_to new_session_path
    end
  end
end
