require 'rails_helper'

RSpec.describe BranchOfficesController, type: :controller do

  describe "modificacion de las estimaciones que le da una sucursal a un tipo de atencion" do

    before(:all) do
      @a1 = FactoryGirl.create(:attention_type)
      @a2 = FactoryGirl.create(:attention_type)
      @a3 = FactoryGirl.create(:attention_type)
      @a4 = FactoryGirl.create(:attention_type)
      @a5 = FactoryGirl.create(:attention_type)
      @a6 = FactoryGirl.create(:attention_type)
    end


    it "reemplaza la lista de estimaciones correctamente" do

      staff = FactoryGirl.create(:supervisor)
      sign_in staff

      # Creo dos listas de estimaciones, con distinto largo, y una ID de atencion igual en ambas listas
      est1 = [{ "attention_type_id": @a1.id , "duration": 30}, { "attention_type_id": @a2.id , "duration": 15},
  		{ "attention_type_id": @a3.id , "duration": 15}]

      est2 = [{ "attention_type_id": @a3.id , "duration": 30}, { "attention_type_id": @a5.id , "duration": 45}]

      branch_office = BranchOffice.find(staff.branch_office_id)
      expect(branch_office.duration_estimations.length).to eq 0

      expect{
        # Hacer la primera actualizacion
        put :update_attention_types_estimations, params: { :id => branch_office.id, :duration_estimations => est1 }
        expect(response).to have_http_status(:ok)
        branch_office.reload
        expect(branch_office.duration_estimations.length).to eq 3
        expect(branch_office.duration_estimations[0].attention_type_id).to eq @a1.id
        expect(branch_office.duration_estimations[1].attention_type_id).to eq @a2.id
        expect(branch_office.duration_estimations[2].attention_type_id).to eq @a3.id
        expect(branch_office.duration_estimations[0].branch_office_id).to eq branch_office.id
        expect(branch_office.duration_estimations[1].branch_office_id).to eq branch_office.id
        expect(branch_office.duration_estimations[2].branch_office_id).to eq branch_office.id
      }.to change(DurationEstimation, :count).by(3)

      expect{
        # Hacer la segunda actualizacion
        put :update_attention_types_estimations, params: { :id => branch_office.id, :duration_estimations => est2 }
        expect(response).to have_http_status(:ok)
        branch_office.reload
        expect(branch_office.duration_estimations.length).to eq 2
        expect(branch_office.duration_estimations[0].attention_type_id).to eq @a3.id
        expect(branch_office.duration_estimations[0].duration).to eq 30
        expect(branch_office.duration_estimations[1].attention_type_id).to eq @a5.id
        expect(branch_office.duration_estimations[1].duration).to eq 45
        expect(branch_office.duration_estimations[0].branch_office_id).to eq branch_office.id
        expect(branch_office.duration_estimations[1].branch_office_id).to eq branch_office.id
      }.to change(DurationEstimation, :count).by(-1) # Se eliminaron las anteriores y ahora hay solo 2


      # No queda ninguna con ID null (prevenir fallas de integridad)
      expect(DurationEstimation.where(:branch_office_id => nil).count).to eq 0

    end

  end

end
