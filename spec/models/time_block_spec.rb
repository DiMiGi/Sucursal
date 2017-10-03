require 'rails_helper'

RSpec.describe TimeBlock, type: :model do
  it "valida valores posibles (correctos)" do
    expect(FactoryGirl.create(:time_block)).to be_valid
    expect(FactoryGirl.create(:time_block, :monday)).to be_valid
    expect(FactoryGirl.create(:time_block, :tuesday)).to be_valid
    expect(FactoryGirl.create(:time_block, :thursday)).to be_valid
    expect(FactoryGirl.create(:time_block, :sunday)).to be_valid

    expect(FactoryGirl.create(:time_block, hour: 8)).to be_valid
    expect(FactoryGirl.create(:time_block, hour: 9)).to be_valid
    expect(FactoryGirl.create(:time_block, hour: 10)).to be_valid
    expect(FactoryGirl.create(:time_block, hour: 11)).to be_valid
    expect(FactoryGirl.create(:time_block, hour: 17)).to be_valid
    expect(FactoryGirl.create(:time_block, hour: 18)).to be_valid
    expect(FactoryGirl.create(:time_block, hour: 10)).to be_valid
    expect(FactoryGirl.create(:time_block, hour: 21)).to be_valid
  end

  it "valida valores posibles (incorrectos)" do
    expect(FactoryGirl.build(:time_block, weekday: 11)).to_not be_valid
    expect(FactoryGirl.build(:time_block, weekday: 11)).to_not be_valid
    expect(FactoryGirl.build(:time_block, hour: 25)).to_not be_valid
    expect(FactoryGirl.build(:time_block, minutes: 16)).to_not be_valid
    expect(FactoryGirl.build(:time_block, minutes: 5)).to_not be_valid
    expect(FactoryGirl.build(:time_block, minutes: -1)).to_not be_valid
    expect(FactoryGirl.build(:time_block, minutes: 50)).to_not be_valid
  end

  it "valida que el personal sea un ejecutivo" do
    expect{FactoryGirl.build(:time_block, executive: FactoryGirl.create(:manager))}.to raise_error ActiveRecord::AssociationTypeMismatch
    expect{FactoryGirl.build(:time_block, executive: FactoryGirl.create(:admin))}.to raise_error ActiveRecord::AssociationTypeMismatch
    expect{FactoryGirl.build(:time_block, executive: FactoryGirl.create(:supervisor))}.to raise_error ActiveRecord::AssociationTypeMismatch
    expect{FactoryGirl.build(:time_block, executive: FactoryGirl.create(:executive))}.to_not raise_error
  end

  context 'ejecutivo que tiene horarios' do

    before(:example) do
      @executive = FactoryGirl.create(:executive)
    end

    it "puede agregar horarios a su lista" do

      expect(@executive.time_blocks.length).to eq 0

      @executive.association(:time_blocks).add_to_target(FactoryGirl.build(:time_block, :monday, hour: 8, minutes: 0))
      @executive.association(:time_blocks).add_to_target(FactoryGirl.build(:time_block, :monday, hour: 9, minutes: 0))
      @executive.association(:time_blocks).add_to_target(FactoryGirl.build(:time_block, :wednesday, hour: 10, minutes: 0))
      @executive.save

      executive2 = Staff.find(@executive.id)

      expect(executive2.time_blocks.length).to eq 3
      expect(executive2.time_blocks[0].hour).to eq 8
      expect(executive2.time_blocks[1].hour).to eq 9
      expect(executive2.time_blocks[2].hour).to eq 10
    end

    it "no se puede agregar horarios repetidos" do
      @executive.association(:time_blocks).add_to_target(FactoryGirl.build(:time_block, :friday, hour: 8, minutes: 0))
      @executive.association(:time_blocks).add_to_target(FactoryGirl.build(:time_block, :friday, hour: 8, minutes: 0))
      expect{ @executive.save }.to raise_error ActiveRecord::RecordNotUnique
      @executive.reload
      expect(@executive.time_blocks.length).to eq 0 # Falla toda la insercion, de ambos
    end


    it "se puede cambiar un horario (lista de bloques) viejo por uno nuevo, incluso si hay bloques iguales en ambos" do

      schedule1 = []
      schedule1 << FactoryGirl.build(:time_block, :friday, hour: 8, minutes: 0)
      schedule1 << FactoryGirl.build(:time_block, :friday, hour: 9, minutes: 15)
      schedule1 << FactoryGirl.build(:time_block, :monday, hour: 10, minutes: 30)

      schedule2 = []
      schedule2 << FactoryGirl.build(:time_block, :thursday, hour: 8, minutes: 0)
      schedule2 << FactoryGirl.build(:time_block, :friday, hour: 9, minutes: 15)
      schedule2 << FactoryGirl.build(:time_block, :monday, hour: 10, minutes: 30)
      schedule2 << FactoryGirl.build(:time_block, :monday, hour: 11, minutes: 30)

      # Primero no tiene bloques
      expect(@executive.time_blocks.length).to eq 0

      # Asignar el primer horario
      @executive.time_blocks = schedule1
      @executive.save
      expect(@executive.time_blocks.length).to eq 3

      # Asignar el segundo horario
      @executive.time_blocks.clear
      @executive.time_blocks = schedule2
      @executive.save
      expect(@executive.time_blocks.length).to eq 4


    end


  end


end
