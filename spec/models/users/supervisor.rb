require 'rails_helper'

RSpec.describe Supervisor, type: :model do

  it "usuario staff con el minimo de requerimientos" do
    supervisor = FactoryGirl.create(:supervisor)
    expect(supervisor).to be_valid
  end

  it "usuario es invalido si no tiene sucursal" do
    supervisor = FactoryGirl.build(:supervisor, :branch_office => nil)
    expect(supervisor).to_not be_valid
  end

end
