class AttentionTypesController < ApplicationController

  def index
    render :json => AttentionType.all.as_json, :status => :ok
  end
end
