require 'rails_helper'

RSpec.describe Appointment, type: :model do
  it "validacion basica" do
    expect(FactoryGirl.build(:appointment)).to be_valid

    executive = FactoryGirl.build(:staff, :executive)
    manager = FactoryGirl.build(:staff, :manager)
    supervisor = FactoryGirl.build(:staff, :supervisor)
    admin = FactoryGirl.build(:staff, :admin)

    expect(FactoryGirl.build(:appointment, :staff => executive)).to be_valid
    expect(FactoryGirl.build(:appointment, :staff => manager)).to_not be_valid
    expect(FactoryGirl.build(:appointment, :staff => supervisor)).to_not be_valid
    expect(FactoryGirl.build(:appointment, :staff => admin)).to_not be_valid

  end
end
