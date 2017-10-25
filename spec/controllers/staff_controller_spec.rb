require 'rails_helper'

RSpec.describe StaffController, type: :controller do

  describe "creacion de usuarios" do
    it "valida la autorizacion" do
      sign_in FactoryGirl.create :executive
      post :create, params: { staff: FactoryGirl.attributes_for(:executive) }
      expect(response).to have_http_status(:redirect)
    end

    it "el usuario creado tiene la misma sucursal que el creador en caso que este ultimo sea un jefe de sucursal" do
      manager = FactoryGirl.create(:manager)
      sign_in manager

      expect {
        executive = FactoryGirl.build(:executive, :names => "alfredito elmo", :branch_office => nil)
        attributes = executive.attributes
        attributes[:password] = '789789456'
        attributes[:password_confirmation] = '789789456'
        post :create, params: { staff: attributes }
        expect(response).to have_http_status(:created)
      }.to change(Executive, :count).by(1)

      expect(Executive.last.names).to eq "Alfredito Elmo"
      expect(Executive.last.branch_office_id).to eq manager.branch_office_id
    end

    it "el usuario creado tiene otra sucursal, pero se cambia automaticamente a la del jefe de sucursal" do
      manager = FactoryGirl.create(:manager)
      sign_in manager
      expect {
        executive = FactoryGirl.build(:executive, :names => "alfredito elmo")
        expect(executive.branch_office_id).to_not eq manager.branch_office_id
        attributes = executive.attributes
        attributes[:password] = '789789456'
        attributes[:password_confirmation] = '789789456'
        post :create, params: { staff: attributes }
        expect(response).to have_http_status(:created)
      }.to change(Executive, :count).by(1)
      expect(Executive.last.names).to eq "Alfredito Elmo"
      expect(Executive.last.branch_office_id).to eq manager.branch_office_id
    end

    it "el administrador crea un usuario con cualquier sucursal" do
      admin = FactoryGirl.create(:admin)
      office = FactoryGirl.create(:branch_office)
      sign_in admin
      expect {
        manager = FactoryGirl.build(:manager, :names => "ramon  julieta", :branch_office => office)
        attributes = manager.attributes
        attributes[:password] = '789789456'
        attributes[:password_confirmation] = '789789456'
        post :create, params: { staff: attributes }
        expect(response).to have_http_status(:created)
      }.to change(Manager, :count).by(1)
      expect(Manager.last.names).to eq "Ramon Julieta"
      expect(Manager.last.branch_office_id).to eq office.id

      office.reload
      expect(office.staff.count).to eq 1
      expect(office.staff[0].names).to eq "Ramon Julieta"

    end
  end


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

        time_block_count = TimeBlock.count

        # Primero el ejecutivo tiene 0 bloques
        expect(executive.time_blocks.length).to eq 0

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

        expect(TimeBlock.count).to eq(time_block_count + 4)

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
        expect(TimeBlock.count).to eq(time_block_count + 5)

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

    describe "administrando modulos de atencion" do
      it "valida el traspaso de horas a un ejecutivo sin horas (el cual siempre existe)" do
        appointments = FactoryGirl.create_list(:appointment, 4)
        executive = FactoryGirl.create(:executive, appointments: appointments)
        replacement_executive = FactoryGirl.create(:executive)
        executive.reassign_appointments_to(replacement_executive)

        expect(replacement_executive.appointments).to include(executive.appointments[0],executive.appointments[1],executive.appointments[2],executive.appointments[3])
      end

    end

end
