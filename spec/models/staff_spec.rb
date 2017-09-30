require 'rails_helper'

RSpec.describe Staff, type: :model do

  it "usuario staff con el minimo de requerimientos" do
    staff = FactoryGirl.create(:staff)
    expect(staff).to be_valid
  end

  it "quita espacios a su nombre al inicio y final y valida luego de eso su largo" do
    staff = FactoryGirl.build(:staff, :names => "                   ")
    expect(staff).to_not be_valid
    staff = FactoryGirl.build(:staff, :first_surname => "     ")
    expect(staff).to_not be_valid
  end

  it "quita espacios a su nombre al inicio y final" do
    staff = FactoryGirl.create(:staff, :names => "              A         ", first_surname: "  bbb  ", second_surname: "  cc ")
    expect(staff).to be_valid
    expect(staff.nombre_completo).to eq "A Bbb Cc"
  end

  it "usuario puede tener nombres y primer apellido pero segundo apellido es opcional" do
    staff = FactoryGirl.create(:staff, :names => "carlos andres", first_surname: "guzman", second_surname: "vilches")
    expect(staff.nombre_completo).to eq "Carlos Andres Guzman Vilches"
    staff = FactoryGirl.create(:staff, :names => "christine  ", first_surname: "pino ", second_surname: "  ")
    expect(staff.nombre_completo).to eq "Christine Pino"
  end

  it "quita espacios dobles en el nombre y pone mayusculas al inicio de cada nombre" do
    staff = FactoryGirl.create(:staff, :names => "  fELipE     ChrisTOPher  ", first_surname: "  díAZ   de    Valdés  ")
    expect(staff).to be_valid
    expect(staff.names).to eq "Felipe Christopher"
    expect(staff.first_surname).to eq "Díaz De Valdés"
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
