class HomeController < ApplicationController

  before_action :authenticate_staff!

  def index
  end
end
