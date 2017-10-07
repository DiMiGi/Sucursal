require 'rails_helper'

RSpec.describe DayOff, type: :model do

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

  it "al borrar una sucursal, se borran en cascada todos sus dias feriados" do

    branch_office = FactoryGirl.create(:branch_office)
    FactoryGirl.create(:branch_office_day_off, branch_office: branch_office)
    FactoryGirl.create(:branch_office_day_off, branch_office: branch_office)
    FactoryGirl.create(:branch_office_day_off, branch_office: branch_office)
    expect(branch_office.days_off.length).to eq 3

    expect{
      branch_office.destroy!
    }.to change(BranchOfficeDayOff, :count).by(-3)

  end

  it "al borrar un dia feriado de una sucursal, esto se refleja en el arreglo de dias feriados de esa sucursal" do
    branch_office = FactoryGirl.create(:branch_office)
    day_off = FactoryGirl.create(:branch_office_day_off, branch_office: branch_office)
    expect(branch_office.days_off.length).to eq 1
    day_off.destroy
    branch_office.reload
    expect(branch_office.days_off.length).to eq 0
  end

  it "al borrar un ejecutivo, se borran sus dias feriados en cascada" do
    executive = FactoryGirl.create(:executive)
    FactoryGirl.create(:executive_day_off, executive: executive)
    FactoryGirl.create(:executive_day_off, executive: executive)
    FactoryGirl.create(:executive_day_off, executive: executive)
    FactoryGirl.create(:executive_day_off, executive: executive)
    expect(executive.days_off.length).to eq 4
    expect{
      executive.destroy!
    }.to change(ExecutiveDayOff, :count).by(-4)
  end

  it "al borrar un dia feriado de un ejecutivo, esto se refleja en el arreglo de dias feriados del ejecutivo" do
    executive = FactoryGirl.create(:executive)
    d1 = FactoryGirl.create(:executive_day_off, executive: executive)
    d2 = FactoryGirl.create(:executive_day_off, executive: executive)
    expect(executive.days_off.length).to eq 2
    d1.destroy!
    executive.reload
    expect(executive.days_off.length).to eq 1
    d2.destroy!
    executive.reload
    expect(executive.days_off.length).to eq 0
  end

end
