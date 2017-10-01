require 'rails_helper'

RSpec.describe BranchOffice, type: :model do

  it "valida que este asociado a una comuna" do
    expect(FactoryGirl.build(:branch_office)).to be_valid
    expect(FactoryGirl.build(:branch_office, :comuna => nil)).to_not be_valid
  end

  it "valida que tenga direccion" do
    expect(FactoryGirl.build(:branch_office, :address => "")).to_not be_valid
    expect(FactoryGirl.build(:branch_office, :address => "   ")).to_not be_valid
    expect(FactoryGirl.build(:branch_office, :address => "\t\n\t")).to_not be_valid
    expect(FactoryGirl.build(:branch_office, :address => "\ta\n\t")).to be_valid
  end

  it "elimina espacios redundantes en la direccion" do
    office = FactoryGirl.create(:branch_office, :address => "\n\na \t  b c\n    \td  ")
    expect(office.address).to eq 'a b c d'
  end

end
