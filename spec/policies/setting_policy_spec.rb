require 'rails_helper'

describe SettingPolicy do

  subject { SettingPolicy.new(staff, nil) }

  context 'siendo un visitor (sin login)' do
    let(:staff) { nil }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'siendo un ejecutivo' do
    let(:staff) { FactoryGirl.create(:staff, :executive) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'siendo un jefe de sucursal' do
    let(:staff) { FactoryGirl.create(:staff, :manager) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'siendo un supervisor' do
    let(:staff) { FactoryGirl.create(:staff, :supervisor) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'siendo un admin' do
    let(:staff) { FactoryGirl.create(:staff, :admin) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:update) }
  end

end
