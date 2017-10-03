require 'rails_helper'

describe SettingPolicy do

  subject { SettingPolicy.new(staff, nil) }

  context 'siendo un visitor (sin login)' do
    let(:staff) { nil }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'siendo un ejecutivo' do
    let(:staff) { FactoryGirl.create(:executive) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'siendo un jefe de sucursal' do
    let(:staff) { FactoryGirl.create(:manager) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'siendo un supervisor' do
    let(:staff) { FactoryGirl.create(:supervisor) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'siendo un admin' do
    let(:staff) { FactoryGirl.create(:admin) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:update) }
  end

end
