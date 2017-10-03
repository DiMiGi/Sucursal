require 'rails_helper'

RSpec.describe DayOff, type: :model do

  it "validacion basica" do
    expect(FactoryGirl.build(:global_day_off)).to be_valid
  end



end
