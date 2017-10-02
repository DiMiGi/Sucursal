require 'rails_helper'

RSpec.describe DurationEstimation, type: :model do

  it "valida que tiene sucursal y tipo de atencion asignado" do
    expect(FactoryGirl.build(:duration_estimation)).to be_valid
    expect(FactoryGirl.build(:duration_estimation, :branch_office => nil)).to_not be_valid
    expect(FactoryGirl.build(:duration_estimation, :attention_type => nil)).to_not be_valid
    expect(FactoryGirl.build(:duration_estimation, :branch_office => nil, :attention_type => nil)).to_not be_valid
  end

  it "valida que numeros de duracion no sean negativos" do
    expect(FactoryGirl.build(:duration_estimation, :duration => -1)).to_not be_valid
  end

  it "valida que numeros de duracion no sean enormes" do
    expect(FactoryGirl.build(:duration_estimation, :duration => 1000)).to_not be_valid
  end

  it "valida que la sucursal exista al momento de crear la estimacion" do
    expect(FactoryGirl.build(:duration_estimation, :branch_office_id => 1000)).to_not be_valid
  end

  it "valida que el tipo de atencion exista al momento de crear la estimacion" do
    expect(FactoryGirl.build(:duration_estimation, :attention_type_id => 1000)).to_not be_valid
  end

end
