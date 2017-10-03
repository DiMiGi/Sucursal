require 'rails_helper'

RSpec.describe Appointment, type: :model do
  it "validacion basica" do
    expect(FactoryGirl.build(:appointment)).to be_valid
    #expect(FactoryGirl.build(:appointment, :executive => nil)).to_not be_valid




  end
end
