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

  it "valida que el tiempo de discretizacion sea divisor de 60 (minutos)" do
    expect(FactoryGirl.build(:branch_office, :minute_discretization => 7)).to_not be_valid
    expect(FactoryGirl.build(:branch_office, :minute_discretization => 13)).to_not be_valid
    expect(FactoryGirl.build(:branch_office, :minute_discretization => 14)).to_not be_valid
    expect(FactoryGirl.build(:branch_office, :minute_discretization => 25)).to_not be_valid
  end

  it "elimina espacios redundantes en la direccion" do
    office = FactoryGirl.create(:branch_office, :address => "\n\na \t  b c\n    \td  ")
    expect(office.address).to eq 'a b c d'
  end

  it "calcula la distancia correctamente" do
    b = FactoryGirl.create(:branch_office, latitude: 10, longitude: 10)
    expect(b.distance(latitude: 20, longitude: 10)).to eq 10
    expect(b.distance(latitude: 10, longitude: 10)).to eq 0
    expect(b.distance(latitude: 19, longitude: 10)).to eq 9
  end


  context 'con estimaciones sobre tipos de atencion' do

    before(:example) do
      @office = FactoryGirl.create(:branch_office)
      @attention1 = FactoryGirl.create(:attention_type, name: "attention #1")
      @attention2 = FactoryGirl.create(:attention_type, name: "attention #2")
      @attention3 = FactoryGirl.create(:attention_type, name: "attention #3")

      estimation1 = DurationEstimation.new(branch_office: @office, attention_type: @attention1, duration: 11)
      estimation2 = DurationEstimation.new(branch_office: @office, attention_type: @attention2, duration: 22)
      estimation3 = DurationEstimation.new(branch_office: @office, attention_type: @attention3, duration: 33)

      @office.duration_estimations << estimation1
      @office.duration_estimations << estimation2
      @office.duration_estimations << estimation3

      @office.save
    end

    it "tiene estimaciones de duracion sobre tipos de atencion" do
      office = BranchOffice.find(@office.id)
      expect(office.duration_estimations.length).to eq 3
      expect(office.duration_estimations[0].attention_type.name).to eq "attention #1"
      expect(office.duration_estimations[1].attention_type.name).to eq "attention #2"
      expect(office.duration_estimations[2].attention_type.name).to eq "attention #3"
      expect(office.duration_estimations[0].duration).to eq 11
      expect(office.duration_estimations[1].duration).to eq 22
      expect(office.duration_estimations[2].duration).to eq 33
    end


    it "arroja error si se quiere agregar una estimacion, cuando ya existe una estimacion para el par sucursal, tipo atencion" do
      expect{
        @office.duration_estimations << DurationEstimation.new(
          attention_type_id: @attention1.id, # Ya fue agregada
          branch_office_id: @office.id,
          duration: 17)
      }.to raise_error ActiveRecord::RecordNotUnique
    end



    it "tiene estimaciones en donde la sucursal es la misma (evitar fallas de integridad)" do
      office = BranchOffice.find(@office.id)
      expect(office.duration_estimations[0].branch_office.id).to eq office.id
      expect(office.duration_estimations[1].branch_office.id).to eq office.id
      expect(office.duration_estimations[2].branch_office.id).to eq office.id
    end
  end
end
