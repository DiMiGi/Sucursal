require 'rails_helper'

RSpec.describe Appointment, type: :model do
  it "validacion basica" do
    expect(FactoryGirl.build(:appointment)).to be_valid
    expect(FactoryGirl.build(:appointment, :executive => nil)).to_not be_valid
    expect(FactoryGirl.build(:appointment, :time => nil)).to_not be_valid
  end


  it "los tiempos se discretizan correctamente" do

    discretizations = [5, 1, 3, 8, 10, 30, 20, 59, 2, 58]
    times = [
      Time.new(2017, 1, 1, 13, 41, 05),
      Time.new(2017, 1, 1, 12, 19, 07),
      Time.new(2017, 1, 1, 10, 17, 30),
      Time.new(2017, 1, 1, 19, 41, 31),
      Time.new(2017, 1, 1, 18, 0, 05),
      Time.new(2017, 1, 1, 15, 59, 59),
      Time.new(2017, 1, 1, 11, 1, 02),
      Time.new(2017, 1, 1,  8, 50, 40),
      Time.new(2017, 1, 1,  9, 37, 01),
      Time.new(2017, 1, 1, 15, 59, 59)
    ]
    results = [
      Time.new(2017, 1, 1, 13, 40, 0),
      Time.new(2017, 1, 1, 12, 19, 0),
      Time.new(2017, 1, 1, 10, 15, 0),
      Time.new(2017, 1, 1, 19, 40, 0),
      Time.new(2017, 1, 1, 18, 0, 0),
      Time.new(2017, 1, 1, 15, 30, 0),
      Time.new(2017, 1, 1, 11, 0, 0),
      Time.new(2017, 1, 1,  8, 0, 0),
      Time.new(2017, 1, 1,  9, 36, 0),
      Time.new(2017, 1, 1, 15, 58, 0)
    ]

    (0..8).each do |i|
      office = FactoryGirl.build(:branch_office, minute_discretization: discretizations[i])
      executive = FactoryGirl.build(:executive, branch_office: office)
      appointment1 = FactoryGirl.create(:appointment, executive: executive, time: times[i])
      appointment2 = FactoryGirl.create(:appointment, executive: executive, time: results[i])
      expect(appointment1.time).to eq appointment2.time
    end
  end


end
