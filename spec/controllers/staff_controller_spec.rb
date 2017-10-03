require 'rails_helper'

RSpec.describe StaffController, type: :controller do

  describe "modificar bloques horarios de un usuario" do

      it "reemplaza la lista de horarios correctamente" do

        attention = FactoryGirl.create(:attention_type)
        office = FactoryGirl.create(:branch_office)

        staff = FactoryGirl.create(:supervisor, attention_type: attention, branch_office: office)
        executive = FactoryGirl.create(:executive, attention_type: attention, branch_office: office)
        sign_in staff

        schedule1 = [
          { weekday: 0, hour: 9, minutes: 45 },
          { weekday: 0, hour: 10, minutes: 0 },
          { weekday: 1, hour: 11, minutes: 15 },
          { weekday: 1, hour: 11, minutes: 30 }
        ]

        schedule2 = [
          { weekday: 5, hour: 9, minutes: 45 },
          { weekday: 0, hour: 10, minutes: 0 },
          { weekday: 2, hour: 11, minutes: 15 },
          { weekday: 2, hour: 11, minutes: 30 },
          { weekday: 3, hour: 11, minutes: 30 }
        ]

        # Primero el ejecutivo tiene 0 bloques, y en total en la BD tambien hay 0
        expect(executive.time_blocks.length).to eq 0
        expect(TimeBlock.count).to eq 0

        # Hacer la primera actualizacion
        put :update_time_blocks, params: { :id => executive.id, :time_blocks => schedule1 }
        expect(response).to have_http_status(:ok)
        executive.reload
        expect(executive.time_blocks.length).to eq 4
        0..4.times do |n|
          expect(executive.time_blocks[n].weekday).to eq schedule1[n][:weekday]
          expect(executive.time_blocks[n].hour).to eq schedule1[n][:hour]
          expect(executive.time_blocks[n].minutes).to eq schedule1[n][:minutes]
          expect(executive.time_blocks[n].executive_id).to eq executive.id
        end

        expect(TimeBlock.count).to eq 4

        # Hacer la segunda actualizacion
        put :update_time_blocks, params: { :id => executive.id, :time_blocks => schedule2 }
        expect(response).to have_http_status(:ok)
        executive.reload
        expect(executive.time_blocks.length).to eq 5
        0..5.times do |n|
          expect(executive.time_blocks[n].weekday).to eq schedule2[n][:weekday]
          expect(executive.time_blocks[n].hour).to eq schedule2[n][:hour]
          expect(executive.time_blocks[n].minutes).to eq schedule2[n][:minutes]
          expect(executive.time_blocks[n].executive_id).to eq executive.id
        end
        expect(TimeBlock.count).to eq 5

        # No queda ninguna con ID null (prevenir fallas de integridad)
        expect(TimeBlock.where(:executive_id => nil).count).to eq 0

      end


      it "valida la autorizacion correcta del usuario que esta tratando de cambiar los horarios de otro usuario" do
        office = FactoryGirl.create(:branch_office)
        sign_in FactoryGirl.create(:executive, branch_office: office)
        executive = FactoryGirl.create(:executive, branch_office: office)
        put :update_time_blocks, params: { :id => executive.id, :time_blocks => [{ weekday: 5, hour: 9, minutes: 45 }] }
        expect(response).to have_http_status(:redirect)
      end





    end




end
