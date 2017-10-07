require 'rails_helper'

RSpec.describe Executive, type: :model do

  it "usuario staff con el minimo de requerimientos" do
    executive = FactoryGirl.create(:executive)
    expect(executive).to be_valid
  end

  it "usuario es invalido si no tiene sucursal" do
    executive = FactoryGirl.build(:executive, :branch_office => nil)
    expect(executive).to_not be_valid
  end


  it "cuando se agregan bloques horarios, estos pueden obtenerse como atributo del ejecutivo" do
    executive = FactoryGirl.create(:executive)
    t1 = FactoryGirl.create(:time_block, executive: executive, hour: 14, minutes: 0)
    t2 = FactoryGirl.create(:time_block, executive: executive, hour: 14, minutes: 15)
    executive.reload
    expect(executive.time_blocks.length).to eq 2
    t2.destroy!
    executive.reload
    expect(executive.time_blocks.length).to eq 1
  end

  it "cuando se borra un ejecutivo, se borran sus bloques horarios" do
    executive = FactoryGirl.create(:executive)
    FactoryGirl.create(:time_block, executive: executive, hour: 14, minutes: 0)
    FactoryGirl.create(:time_block, executive: executive, hour: 14, minutes: 15)
    FactoryGirl.create(:time_block, executive: executive, hour: 14, minutes: 30)
    expect{ executive.destroy! }.to change(TimeBlock, :count).by(-3)
  end

end
