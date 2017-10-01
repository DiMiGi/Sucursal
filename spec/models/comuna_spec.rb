require 'rails_helper'

RSpec.describe Comuna, type: :model do
  it "valida que este asociado a una region" do
    expect(FactoryGirl.build(:comuna)).to be_valid
    expect(FactoryGirl.build(:comuna, :region => nil)).to_not be_valid
  end
end
