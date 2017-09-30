require 'rails_helper'

RSpec.describe Staff, type: :model do

  it "usuario staff con el minimo de requerimientos" do
    staff = FactoryGirl.create(:staff)
    expect(staff).to be_valid
  end

  it "quita espacios a su nombre al inicio y final y valida luego de eso su largo" do
    staff = FactoryGirl.build(:staff, :fullname => "                           ")
    expect(staff).to_not be_valid
  end

  it "quita espacios a su nombre al inicio y final" do
    staff = FactoryGirl.create(:staff, :fullname => "              A             ")
    expect(staff).to be_valid
    expect(staff.fullname).to eq "A"
  end

  it "quita espacios dobles en el nombre y pone mayusculas al inicio de cada nombre" do
    staff = FactoryGirl.create(:staff, :fullname => "  fELipE     VilCHES ")
    expect(staff).to be_valid
    expect(staff.fullname).to eq "Felipe Vilches"
  end

  it "dos usuarios no pueden tener el mismo correo electronico" do
    FactoryGirl.create(:staff, :email => " hola@correo.es   ")
    staff = FactoryGirl.build(:staff, :email => "   hoLA@CorReO.eS ")
    expect(staff).to_not be_valid
  end

  it "usuario perteneciente a sucursal sin sucursal asignada es invalido" do
    staff = FactoryGirl.build(:staff, :executive, :branch_office => nil)
    expect(staff).to_not be_valid

    staff = FactoryGirl.build(:staff, :supervisor, :branch_office => nil)
    expect(staff).to_not be_valid

    staff = FactoryGirl.build(:staff, :manager, :branch_office => nil)
    expect(staff).to_not be_valid
  end

  it "usuario administrador es invalido cuando tiene asignada una sucursal" do
    staff = FactoryGirl.build(:staff, :admin, :branch_office => FactoryGirl.create(:branch_office))
    expect(staff).to_not be_valid

    staff = FactoryGirl.build(:staff, :admin, :branch_office => nil)
    expect(staff).to be_valid
  end


end
