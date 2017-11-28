require 'rails_helper'


RSpec.describe AppointmentsController, type: :ctrl do

  describe "funcion que obtiene las notificaciones en sus horas y dias correctas" do

    let(:ctrl) { AppointmentsController.new }


    it "pone una notificacion 24 horas antes solo si es que hay un dia entre medio" do

      expect(ctrl.create_notifications(
        start: Time.zone.parse('2017-10-05 12:00:00'),
        finish: Time.zone.parse('2017-10-06 12:00:00'),
        quantity: 3).length).to eq 1

      expect(ctrl.create_notifications(
        start: Time.zone.parse('2017-10-05 12:00:00'),
        finish: Time.zone.parse('2017-10-07 12:00:00'),
        quantity: 3).length).to eq 2

      expect(ctrl.create_notifications(
        start: Time.zone.parse('2017-10-05 12:00:00'),
        finish: Time.zone.parse('2017-10-08 12:00:00'),
        quantity: 3).length).to eq 2

    end

  end

end
