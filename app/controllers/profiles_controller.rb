# typed: false
# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[ show edit update ]
  def show; end

  def new
    if current_user.profile.present?
      redirect_to edit_profile_path(current_user.profile), notice: t("messages.already_exists")
    else
      @profile = current_user.build_profile
    end
  end

  def create
    @profile = current_user.build_profile(profile_params)

    if @profile.save
      redirect_to profile_url(@profile), notice: t("messages.created", model: Profile.model_name.human)
    else
      flash.now[:error] = @profile.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @profile.update(profile_params)
      redirect_to profile_url(@profile)
      flash[:notice] = t("messages.updated", model: Profile.model_name.human)
    else
      flash.now[:error] = @profile.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :username, :bio, :avatar)
  end

  def set_profile
    @profile = current_user.profile
    raise ActiveRecord::RecordNotFound unless @profile && @profile.id.to_s == params[:id]
  end
end
