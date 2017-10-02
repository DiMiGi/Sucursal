require 'rails_helper'

RSpec.describe BranchOfficesController, type: :controller do

=begin
  describe "Unauthorized" do
      login_as_moderator

      it "cannot create" do
        post :create, params: {}
        expect(response).to have_http_status(:unauthorized)
      end
      it "cannot update" do
        put :update, params: { id: 2 }
        expect(response).to have_http_status(:unauthorized)
      end
      it "cannot destroy" do
        delete :destroy, params: { id: 2 }
        expect(response).to have_http_status(:unauthorized)
      end
    end

=end
end
