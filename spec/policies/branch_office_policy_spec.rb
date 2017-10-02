require 'rails_helper'

describe BranchOfficePolicy do

  subject { BranchOfficePolicy.new(staff, branch_office) }

  context 'modificando estimaciones de duracion de tipo de atencion' do

    context 'siendo un visitor (sin login)' do
      let(:staff) { nil }
      let(:branch_office) { FactoryGirl.create(:branch_office) }
      it { is_expected.to forbid_action(:update_attention_types_estimations) }
    end

    context 'siendo administrador' do
      let(:staff) { FactoryGirl.create(:staff, :admin) }
      let(:branch_office) { FactoryGirl.create(:branch_office) }
      it { is_expected.to permit_action(:update_attention_types_estimations) }
    end

    context 'siendo ejecutivo' do
      let(:staff) { FactoryGirl.create(:staff, :executive) }
      let(:branch_office) { FactoryGirl.create(:branch_office) }
      it { is_expected.to forbid_action(:update_attention_types_estimations) }
    end

    context 'siendo supervisor' do
      branch_office = FactoryGirl.create(:branch_office)
      supervisor = FactoryGirl.create(:staff, :supervisor, :branch_office => branch_office)
      let(:staff) { supervisor }
      let(:branch_office) { branch_office }
      it { is_expected.to permit_action(:update_attention_types_estimations) }
    end

    context 'siendo jefe de sucursal' do
      branch_office = FactoryGirl.create(:branch_office)
      manager = FactoryGirl.create(:staff, :manager, :branch_office => branch_office)
      let(:staff) { manager }
      let(:branch_office) { branch_office }
      it { is_expected.to permit_action(:update_attention_types_estimations) }
    end

    context 'cuando el personal pertence a sucursal distinta prohibe la accion' do
      context 'siendo supervisor' do
        office1 = FactoryGirl.create(:branch_office)
        office2 = FactoryGirl.create(:branch_office)
        supervisor = FactoryGirl.create(:staff, :manager, :branch_office => office1)
        let(:staff) { supervisor }
        let(:branch_office) { office2 }
        it { is_expected.to forbid_action(:update_attention_types_estimations) }
      end
      context 'siendo jefe de sucursal' do
        office1 = FactoryGirl.create(:branch_office)
        office2 = FactoryGirl.create(:branch_office)
        manager = FactoryGirl.create(:staff, :manager, :branch_office => office1)
        let(:staff) { manager }
        let(:branch_office) { office2 }
        it { is_expected.to forbid_action(:update_attention_types_estimations) }
      end
    end

  end
end
