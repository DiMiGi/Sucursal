require 'rails_helper'

RSpec.describe Executive, type: :model do

  pending "Cuando se borra un ejecutivo, debe borrarse sus bloques horarios"

  it "usuario staff con el minimo de requerimientos" do
    executive = FactoryGirl.create(:executive)
    expect(executive).to be_valid
  end

  it "usuario es invalido si no tiene sucursal" do
    executive = FactoryGirl.build(:executive, :branch_office => nil)
    expect(executive).to_not be_valid
  end

end
