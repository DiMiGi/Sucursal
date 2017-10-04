require 'rails_helper'

RSpec.describe DayOff, type: :model do

  pending "Cuando se borra una sucursal o ejecutivo, debe borrarse sus dias inactivos"

  it "validacion basica" do
    expect(FactoryGirl.build(:global_day_off)).to be_valid
    expect(FactoryGirl.build(:branch_office_day_off)).to be_valid
    expect(FactoryGirl.build(:executive_day_off)).to be_valid
  end

  it "permite buscar por sucursal/ejecutivo, o global, y las consultas las hace solo por la clase que se esta buscando" do

    executive1 = FactoryGirl.create(:executive)
    executive2 = FactoryGirl.create(:executive)

    total = DayOff.count
    global_count = GlobalDayOff.count
    branch_office_count = BranchOfficeDayOff.count
    executive_count = ExecutiveDayOff.count
    executive1_count = ExecutiveDayOff.where(:executive => executive1).count
    executive2_count = ExecutiveDayOff.where(:executive => executive2).count

    FactoryGirl.create(:global_day_off)
    FactoryGirl.create(:global_day_off)
    FactoryGirl.create(:global_day_off)
    FactoryGirl.create(:branch_office_day_off)
    FactoryGirl.create(:executive_day_off, :executive => executive1)
    FactoryGirl.create(:executive_day_off, :executive => executive1)
    FactoryGirl.create(:executive_day_off, :executive => executive2)

    expect(GlobalDayOff.count).to eq(global_count + 3)
    expect(BranchOfficeDayOff.count).to eq(branch_office_count + 1)
    expect(ExecutiveDayOff.count).to eq(executive_count + 3)
    expect(ExecutiveDayOff.where(:executive => executive1).count).to eq(executive1_count + 2)
    expect(ExecutiveDayOff.where(:executive => executive2).count).to eq(executive2_count + 1)
    expect(DayOff.count).to eq(total + 7)

  end

end
