require 'pp'

class SettingsController < ApplicationController

  before_action :authenticate_staff!

  def pundit_user
    current_staff
  end

  def index
    authorize Setting
    @settings = Setting.get_all
  end

  def update
    authorize Setting

    keys = []

    params[:data].each do |key|
      keys << key
    end

    settings = Setting.where(var: keys)

    settings.each do |setting|
      setting.value = params[:data][setting.var]
      setting.save
    end

    render :json => :ok
  end

end
