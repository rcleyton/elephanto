# typed: false
# frozen_string_literal: true

class LandingController < ApplicationController
  allow_unauthenticated_access only: %i[ index terms privacy ]
  layout "landing"
end
