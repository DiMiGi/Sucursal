require 'rails_helper'

RSpec.describe Staff, type: :model do

  it "usuario staff con el minimo de requerimientos" do
    staff = FactoryGirl.create(:staff)
    expect(staff).to be_valid
  end

  it "valida usuarios sin primer apellido" do
    expect(FactoryGirl.build(:staff, :first_surname => "")).to_not be_valid
    expect(FactoryGirl.build(:staff, :first_surname => "  ")).to_not be_valid
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
    expect(staff.full_name).to eq "A Bbb Cc"
  end

  it "usuario puede tener nombres y primer apellido pero segundo apellido es opcional" do
    staff = FactoryGirl.create(:staff, :names => "carlos andres", first_surname: "guzman", second_surname: "vilches")
    expect(staff.full_name).to eq "Carlos Andres Guzman Vilches"
    staff = FactoryGirl.create(:staff, :names => "christine  ", first_surname: "pino ", second_surname: "  ")
    expect(staff.full_name).to eq "Christine Pino"
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

  it "muestra correctamente el nombre corto (es decir, primer nombre y primer apellido)" do
    staff = FactoryGirl.create(:staff, names: " felipe   chris", first_surname: "  vilch")
    expect(staff.name_surname).to eq "Felipe Vilch"

    staff = FactoryGirl.create(:staff, names: "   a", first_surname: "  díAZ   dE Valdés", second_surname: "qqwweerty")
    expect(staff.name_surname).to eq "A Díaz De Valdés"
  end

  it "las consultas find() sobre las subclases de usuario entregan solo esos usuarios" do

    Staff.destroy_all
    FactoryGirl.create(:supervisor)
    FactoryGirl.create(:supervisor)
    FactoryGirl.create(:supervisor)
    FactoryGirl.create(:admin)
    FactoryGirl.create(:admin)
    FactoryGirl.create(:executive)
    FactoryGirl.create(:manager)
    FactoryGirl.create(:manager)
    FactoryGirl.create(:manager)

    expect(Admin.count).to eq 2
    expect(Executive.count).to eq 1
    expect(Manager.count).to eq 3
    expect(Supervisor.count).to eq 3

  end



end
