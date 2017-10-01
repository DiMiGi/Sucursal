class SettingsController < ApplicationController

  before_action :authenticate_staff!

  def pundit_user
    current_staff
  end

  def index
  end

  def update
    authorize Setting

    params[:data].each do |key, value|
      Setting[key] = value
    end

    render :json => { :error => msg }, :status => :ok

  end

end
