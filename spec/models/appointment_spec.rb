require 'rails_helper'

RSpec.describe Appointment, type: :model do
  it "validacion basica" do
    expect(FactoryGirl.build(:appointment)).to be_valid
    expect(FactoryGirl.build(:appointment, :executive => nil)).to_not be_valid
    expect(FactoryGirl.build(:appointment, :time => nil)).to_not be_valid
  end

  it "permite buscar por dia correctamente" do

    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 1, 1, 13, 41, 05))
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 1, 1, 13, 41, 05))
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 1, 2, 13, 41, 05))
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 2, 3, 0, 0, 0))
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 2, 3, 13, 41, 05))
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 2, 3, 23, 59, 59))
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 2, 4, 0, 0, 0))
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 2, 5, 0, 0, 0))
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 5, 5, 0, 0, 0))
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 5, 5, 23, 59, 59))
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 5, 6, 0, 0, 0))

    expect(Appointment.find_by_day(Date.new(2018, 1, 1)).count).to eq 2
    expect(Appointment.find_by_day(Date.new(2018, 1, 2)).count).to eq 1
    expect(Appointment.find_by_day(Date.new(2018, 2, 3)).count).to eq 3
    expect(Appointment.find_by_day(Date.new(2018, 2, 4)).count).to eq 1
    expect(Appointment.find_by_day(Date.new(2018, 2, 5)).count).to eq 1
    expect(Appointment.find_by_day(Date.new(2018, 5, 5)).count).to eq 2
    expect(Appointment.find_by_day(Date.new(2018, 5, 6)).count).to eq 1

  end

  it "permite buscar por dia correctamente, y ademas con otros atributos" do
    ex1 = FactoryGirl.create(:executive)
    ex2 = FactoryGirl.create(:executive)
    ex3 = FactoryGirl.create(:executive)
    ex4 = FactoryGirl.create(:executive)

    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 1, 1, 13, 41, 05), :executive => ex1)
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 1, 1, 13, 41, 05), :executive => ex2)
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 1, 2, 13, 41, 05), :executive => ex2)
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 2, 3, 0, 0, 0), :executive => ex1)
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 2, 3, 13, 1, 13), :executive => ex1)
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 2, 3, 23, 2, 47), :executive => ex1)
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 2, 3, 13, 41, 05), :executive => ex2)
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 2, 3, 23, 59, 59), :executive => ex3)
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 2, 4, 0, 0, 0), :executive => ex4)
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 2, 5, 0, 0, 0), :executive => ex4)
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 5, 5, 0, 0, 0), :executive => ex3)
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 5, 5, 23, 59, 59), :executive => ex4)
    FactoryGirl.create(:appointment, :time => DateTime.new(2018, 5, 6, 0, 0, 0), :executive => ex3)

    expect(Appointment.find_by_day(Date.new(2018, 1, 1)).where(:executive => ex1).count).to eq 1
    expect(Appointment.find_by_day(Date.new(2018, 1, 2)).where(:executive => ex1).count).to eq 0
    expect(Appointment.find_by_day(Date.new(2018, 1, 2)).where(:executive => ex2).count).to eq 1
    expect(Appointment.find_by_day(Date.new(2018, 2, 3)).where(:executive => ex2).count).to eq 1
    expect(Appointment.find_by_day(Date.new(2018, 2, 3)).where(:executive => ex1).count).to eq 3
    expect(Appointment.find_by_day(Date.new(2018, 2, 1)).where(:executive => ex1).count).to eq 0
    expect(Appointment.find_by_day(Date.new(2018, 5, 5)).where(:executive => ex1).count).to eq 0
    expect(Appointment.find_by_day(Date.new(2018, 5, 5)).where(:executive => ex2).count).to eq 0
    expect(Appointment.find_by_day(Date.new(2018, 5, 5)).where(:executive => ex3).count).to eq 1
    expect(Appointment.find_by_day(Date.new(2018, 5, 5)).where(:executive => ex4).count).to eq 1
    expect(Appointment.find_by_day(Date.new(2018, 5, 6)).where(:executive => ex3).count).to eq 1

  end




  it "los tiempos se discretizan correctamente" do

    discretizations = [5, 1, 3, 8, 10, 30, 20, 59, 2, 58]
    times = [
      DateTime.new(2017, 1, 1, 13, 41, 05),
      DateTime.new(2017, 1, 1, 12, 19, 07),
      DateTime.new(2017, 1, 1, 10, 17, 30),
      DateTime.new(2017, 1, 1, 19, 41, 31),
      DateTime.new(2017, 1, 1, 18, 0, 05),
      DateTime.new(2017, 1, 1, 15, 59, 59),
      DateTime.new(2017, 1, 1, 11, 1, 02),
      DateTime.new(2017, 1, 1,  8, 50, 40),
      DateTime.new(2017, 1, 1,  9, 37, 01),
      DateTime.new(2017, 1, 1, 15, 59, 59)
    ]
    results = [
      DateTime.new(2017, 1, 1, 13, 40, 0),
      DateTime.new(2017, 1, 1, 12, 19, 0),
      DateTime.new(2017, 1, 1, 10, 15, 0),
      DateTime.new(2017, 1, 1, 19, 40, 0),
      DateTime.new(2017, 1, 1, 18, 0, 0),
      DateTime.new(2017, 1, 1, 15, 30, 0),
      DateTime.new(2017, 1, 1, 11, 0, 0),
      DateTime.new(2017, 1, 1,  8, 0, 0),
      DateTime.new(2017, 1, 1,  9, 36, 0),
      DateTime.new(2017, 1, 1, 15, 58, 0)
    ]

    (0..8).each do |i|
      office = FactoryGirl.build(:branch_office, minute_discretization: discretizations[i])
      executive = FactoryGirl.build(:executive, branch_office: office)
      appointment1 = FactoryGirl.create(:appointment, executive: executive, time: times[i])
      appointment2 = FactoryGirl.create(:appointment, executive: executive, time: results[i])
      expect(appointment1.time).to eq appointment2.time
      expect(appointment1).to be_valid
      expect(appointment2).to be_valid
    end
  end


end
