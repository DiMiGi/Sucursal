require 'rails_helper'

RSpec.describe Appointment, type: :model do

  it "validacion basica" do
    expect(FactoryGirl.build(:appointment)).to be_valid
    expect(FactoryGirl.build(:appointment, :status => :normal)).to be_valid
    expect(FactoryGirl.build(:appointment, :status => :cancelled)).to be_valid
    expect(FactoryGirl.build(:appointment, :status => 0)).to be_valid
    expect(FactoryGirl.build(:appointment, :status => 1)).to be_valid
    expect(FactoryGirl.build(:appointment, :status => 2)).to be_valid

    expect{FactoryGirl.build(:appointment, :status => 3)}.to raise_error ArgumentError
    expect{FactoryGirl.build(:appointment, :status => :invalid_qwerty)}.to raise_error ArgumentError

    expect(FactoryGirl.build(:appointment, :executive => nil)).to_not be_valid
    expect(FactoryGirl.build(:appointment, :time => nil)).to_not be_valid

  end

  it "crea una cita en status normal por defecto" do
    e = FactoryGirl.create(:executive)
    a = Appointment.new
    a.executive = e
    a.time = Time.current
    a.client_id = "10000"
    a.client_names = "José Manuel Jimenez"
    a.save!
    expect(a.status.to_sym).to eq :normal
  end

  it "cuando se agregan o borran citas, se pueden obtener desde el atributo del ejecutivo las citas que tiene" do

    executive = FactoryGirl.create(:executive)
    expect(executive.appointments.length).to eq 0

    FactoryGirl.create(:appointment, executive: executive, time: Time.zone.parse('2018-1-1 13:40:7'))
    executive.reload
    expect(executive.appointments.length).to eq 1

    FactoryGirl.create(:appointment, executive: executive, time: Time.zone.parse('2018-1-1 15:20:7'))
    executive.reload
    expect(executive.appointments.length).to eq 2

    Appointment.where(executive: executive, time: Time.zone.parse('2018-1-1 15:20:0')).delete_all
    executive.reload
    expect(executive.appointments.length).to eq 1
  end

  it "cuando se agrega una hora, se mantiene coherencia con la zona horaria (la hora no se cambia en la base de datos)" do

    executive = FactoryGirl.create(:executive)
    FactoryGirl.create(:appointment, executive: executive, time: Time.zone.parse('2018-1-1 13:40:7'))

    t = executive.appointments[0].time

    expect(t).to eq Time.zone.parse('2018-1-1 13:40:00')

    expect(t.year).to eq 2018
    expect(t.month).to eq 1
    expect(t.day).to eq 1
    expect(t.hour).to eq 13
    expect(t.min).to eq 40
    expect(t.sec).to eq 0

    a = Appointment.find_by executive: executive, time: Time.zone.parse('2018-1-1 13:40:0')
    expect(a).to_not be_nil

  end

  it "permite buscar por dia correctamente" do

    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-01-01 13:41:05'))
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-1-1 13:41:05'))
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-1-2 13:41:05'))
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-2-3 0:0:0'))
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-2-3 13:41:05'))
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-2-3 23:59:59'))
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-2-4 0:0:0'))
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-2-5 0:0:0'))
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-5-5 0:0:0'))
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-5-5 23:59:59'))
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-5-6 0:0:0'))

    expect(Appointment.find_by_day(Time.zone.parse('2018-01-01')).count).to eq 2
    expect(Appointment.find_by_day(Time.zone.parse('2018-01-02')).count).to eq 1
    expect(Appointment.find_by_day(Time.zone.parse('2018-02-03')).count).to eq 3
    expect(Appointment.find_by_day(Time.zone.parse('2018-02-04')).count).to eq 1
    expect(Appointment.find_by_day(Time.zone.parse('2018-02-05')).count).to eq 1
    expect(Appointment.find_by_day(Time.zone.parse('2018-05-05')).count).to eq 2
    expect(Appointment.find_by_day(Time.zone.parse('2018-05-06')).count).to eq 1

  end

  it "permite buscar por dia correctamente, y ademas con otros atributos" do
    ex1 = FactoryGirl.create(:executive)
    ex2 = FactoryGirl.create(:executive)
    ex3 = FactoryGirl.create(:executive)
    ex4 = FactoryGirl.create(:executive)

    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-1-1 13:41:05'), :executive => ex1)
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-1-1 13:41:05'), :executive => ex2)
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-1-2 13:41:05'), :executive => ex2)
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-2-3 0:0:0'), :executive => ex1)
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-2-3 13:1:13'), :executive => ex1)
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-2-3 23:2:47'), :executive => ex1)
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-2-3 13:41:05'), :executive => ex2)
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-2-3 23:59:59'), :executive => ex3)
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-2-4 0:0:0'), :executive => ex4)
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-2-5 0:0:0'), :executive => ex4)
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-5-5 0:0:0'), :executive => ex3)
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-5-5 23:59:59'), :executive => ex4)
    FactoryGirl.create(:appointment, :time => Time.zone.parse('2018-5-6 0:0:0'), :executive => ex3)

    expect(Appointment.find_by_day(Time.zone.parse('2018-1-1')).where(:executive => ex1).count).to eq 1
    expect(Appointment.find_by_day(Time.zone.parse('2018-1-2')).where(:executive => ex1).count).to eq 0
    expect(Appointment.find_by_day(Time.zone.parse('2018-1-2')).where(:executive => ex2).count).to eq 1
    expect(Appointment.find_by_day(Time.zone.parse('2018-2-3')).where(:executive => ex2).count).to eq 1
    expect(Appointment.find_by_day(Time.zone.parse('2018-2-3')).where(:executive => ex1).count).to eq 3
    expect(Appointment.find_by_day(Time.zone.parse('2018-2-1')).where(:executive => ex1).count).to eq 0
    expect(Appointment.find_by_day(Time.zone.parse('2018-5-5')).where(:executive => ex1).count).to eq 0
    expect(Appointment.find_by_day(Time.zone.parse('2018-5-5')).where(:executive => ex2).count).to eq 0
    expect(Appointment.find_by_day(Time.zone.parse('2018-5-5')).where(:executive => ex3).count).to eq 1
    expect(Appointment.find_by_day(Time.zone.parse('2018-5-5')).where(:executive => ex4).count).to eq 1
    expect(Appointment.find_by_day(Time.zone.parse('2018-5-6')).where(:executive => ex3).count).to eq 1

  end




  it "los tiempos se discretizan correctamente, siendo redondeados hacia abajo" do

    discretizations = [5, 1, 3, 8, 10, 30, 20, 59, 2, 58, 7, 8, 8, 6]
    times = [
      Time.zone.parse('2017-1-1 13:41:05'),
      Time.zone.parse('2017-1-1 12:19:07'),
      Time.zone.parse('2017-1-1 10:17:30'),
      Time.zone.parse('2017-1-1 19:41:31'),
      Time.zone.parse('2017-1-1 18:0:05'),
      Time.zone.parse('2017-1-1 15:59:59'),
      Time.zone.parse('2017-1-1 11:1:02'),
      Time.zone.parse('2017-1-1 8:50:40'),
      Time.zone.parse('2017-1-1 9:37:01'),
      Time.zone.parse('2017-1-1 15:59:59'),
      Time.zone.parse('2017-1-1 15:13:45'),
      Time.zone.parse('2017-1-1 15:13:45'),
      Time.zone.parse('2017-1-1 15:25:39'),
      Time.zone.parse('2017-1-1 15:11:40')
    ]
    results = [
      Time.zone.parse('2017-1-1 13:40:0'),
      Time.zone.parse('2017-1-1 12:19:0'),
      Time.zone.parse('2017-1-1 10:15:0'),
      Time.zone.parse('2017-1-1 19:40:0'),
      Time.zone.parse('2017-1-1 18:0:0'),
      Time.zone.parse('2017-1-1 15:30:0'),
      Time.zone.parse('2017-1-1 11:0:0'),
      Time.zone.parse('2017-1-1 8:0:0'),
      Time.zone.parse('2017-1-1 9:36:0'),
      Time.zone.parse('2017-1-1 15:58:0'),
      Time.zone.parse('2017-1-1 15:7:0'),
      Time.zone.parse('2017-1-1 15:8:0'),
      Time.zone.parse('2017-1-1 15:24:0'),
      Time.zone.parse('2017-1-1 15:6:0')
    ]


    times.each_with_index do |item, i|
      office = FactoryGirl.build(:branch_office, minute_discretization: discretizations[i])
      executive = FactoryGirl.build(:executive, branch_office: office)
      appointment = FactoryGirl.create(:appointment, executive: executive, time: item)
      expect(appointment.time).to eq results[i]
    end
  end

  it "valida asignacion de usuario que atiende a cliente" do

    first_office = FactoryGirl.build(:branch_office)
    second_office = FactoryGirl.build(:branch_office)

    supervisor = FactoryGirl.build(:supervisor, :branch_office => first_office)
    manager = FactoryGirl.build(:manager, :branch_office => first_office)

    first_executive = FactoryGirl.build(:executive, :branch_office => first_office)
    second_executive = FactoryGirl.build(:executive, :branch_office => first_office)
    third_executive = FactoryGirl.build(:executive, :branch_office => second_office)

    appointment_valid = FactoryGirl.build(:appointment,:executive => first_executive, client_id: "1000", :staff_took_appointment => second_executive)
    expect(appointment_valid).to be_valid
    appointment_valid = FactoryGirl.build(:appointment,:executive => first_executive, client_id: "1000", :staff_took_appointment => first_executive)
    expect(appointment_valid).to be_valid
    appointment_valid = FactoryGirl.build(:appointment,:executive => first_executive, client_id: "1000", :staff_took_appointment => manager)
    expect(appointment_valid).to be_valid
    appointment_valid = FactoryGirl.build(:appointment,:executive => first_executive, client_id: "1000", :staff_took_appointment => supervisor)
    expect(appointment_valid).to be_valid
    appointment_not_valid = FactoryGirl.build(:appointment,:executive => first_executive, client_id: "1000", :staff_took_appointment => third_executive)
    expect(appointment_not_valid).to_not be_valid
  end

  it "valida finalizacion de hora por cada usuario" do
    first_office = FactoryGirl.create(:branch_office)

    first_executive = FactoryGirl.create(:executive, :branch_office => first_office)

    second_executive = FactoryGirl.create(:executive, :branch_office => first_office)
    supervisor = FactoryGirl.build(:supervisor, :branch_office => first_office)
    manager = FactoryGirl.build(:manager, :branch_office => first_office)

    appointment = FactoryGirl.create(:appointment,:executive => first_executive, client_id: "1000")

    appointment.finalize_appointment(second_executive)
    expect(Appointment.find(appointment.id).staff_took_appointment).to eq second_executive

    appointment.finalize_appointment(supervisor)
    expect(Appointment.find(appointment.id).staff_took_appointment).to eq supervisor

    appointment.finalize_appointment(manager)
    expect(Appointment.find(appointment.id).staff_took_appointment).to eq manager
  end


end
