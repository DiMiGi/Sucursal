require 'rails_helper'

RSpec.describe AppointmentsController, type: :controller do

  describe "algoritmo para obtener horarios libres para una reunion" do

    let(:controller) { AppointmentsController.new }

    it "entrega las horas libres correctas" do

      a = controller.getFreeBlocks(day: 5, branch_office: 7, attention_type: 9)

      expect(a).to eq 1

    end

  end


end
