class ApplicationController < ActionController::Base
  #protect_from_forgery with: :exception
  include Pundit


  rescue_from Pundit::NotAuthorizedError, with: :policy_fail

  protected
  def policy_fail(exception)

    msg = "No esta autorizado para esta operación."

    respond_to do |format|
      format.json {
        render :json => { :error => msg }, :status => :bad_request
      }
      format.html {
        flash[:error] = msg
        redirect_to root_path
      }
    end
  end


end
