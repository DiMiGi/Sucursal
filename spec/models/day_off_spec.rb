require 'rails_helper'

RSpec.describe DayOff, type: :model do

  it "valida los distintos tipos de asignacion (global, por sucursal, o por ejecutivo)" do
    expect(FactoryGirl.build(:day_off, :global)).to be_valid
    expect(FactoryGirl.build(:day_off, :executive)).to be_valid
    expect(FactoryGirl.build(:day_off, :branch_office)).to be_valid
    expect(FactoryGirl.build(:day_off, branch_office: nil, staff: nil)).to be_valid
    executive = FactoryGirl.build(:staff, :executive)
    expect(FactoryGirl.build(:day_off, branch_office: nil, staff: executive)).to be_valid
  end

  it "valida los errores de creacion (mezclando global con sucursal, etc)" do
    executive = FactoryGirl.build(:staff, :executive)
    manager = FactoryGirl.build(:staff, :manager)
    branch_office = FactoryGirl.build(:branch_office)
    expect(FactoryGirl.build(:day_off, staff: executive, branch_office: branch_office)).to_not be_valid
    expect(FactoryGirl.build(:day_off, staff: manager, branch_office: nil)).to_not be_valid
  end

  it "valida el atributo dia" do
    expect{FactoryGirl.create(:day_off, :day => Date.new(2001, 2, 300))}.to raise_error ArgumentError
    expect{FactoryGirl.create(:day_off, :day => Date.new(2001, 2, 30))}.to raise_error ArgumentError
    expect{FactoryGirl.create(:day_off, :day => Date.new(2001, 2, 100))}.to raise_error ArgumentError
  end

  it "puede realizar busquedas por dia" do
    FactoryGirl.create(:day_off, :day => Date.new(2024, 2, 5))
    FactoryGirl.create(:day_off, :day => Date.new(2024, 2, 5))
    FactoryGirl.create(:day_off, :day => Date.new(2024, 2, 6))
    FactoryGirl.create(:day_off, :day => Date.new(2024, 2, 6))
    FactoryGirl.create(:day_off, :day => Date.new(2024, 2, 7))
    expect(DayOff.where(day: Date.new(2024, 2, 5)).count).to eq 2
    expect(DayOff.where(day: Date.new(2024, 2, 6)).count).to eq 2
    expect(DayOff.where(day: Date.new(2024, 2, 7)).count).to eq 1
  end

end
