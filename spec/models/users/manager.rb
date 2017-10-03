require 'rails_helper'

RSpec.describe Manager, type: :model do

  it "usuario staff con el minimo de requerimientos" do
    manager = FactoryGirl.create(:manager)
    expect(manager).to be_valid
  end

  it "usuario es invalido si no tiene sucursal" do
    manager = FactoryGirl.build(:manager, :branch_office => nil)
    expect(manager).to_not be_valid
  end

end
