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

    ActiveRecord::Base.transaction do
      params[:data].each do |key, value|
        setting = Setting.find_by(var: key) || Setting.new(var: key, value: value)
        setting.value = value
        setting.save
      end
    end

    render :json => :ok
  end

end
