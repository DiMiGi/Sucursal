require 'rails_helper'

describe StaffPolicy do

  subject { StaffPolicy.new(staff, staff2) }

  context 'crear un usuario' do

    context 'crear usuario siendo un visitor (sin login)' do
      let(:staff) { nil }
      let(:staff2) { nil }
      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:create) }
    end

    context 'crear usuario siendo un ejecutivo' do
      let(:staff) { FactoryGirl.build(:staff, :executive) }
      let(:staff2) { nil }
      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:create) }
    end

    context 'crear usuario siendo un supervisor' do
      let(:staff) { FactoryGirl.build(:staff, :supervisor) }
      let(:staff2) { nil }
      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:create) }
    end

    context 'crear usuario siendo un administrador' do
      let(:staff) { FactoryGirl.build(:staff, :admin) }
      let(:staff2) { FactoryGirl.build(:staff) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
    end


    context 'crear usuario siendo un jefe de sucursal' do

      # Primero verificar si puede entrar a la pagina del formulario
      staff = FactoryGirl.create(:staff, :manager)
      branch_office = staff.branch_office_id
      let(:staff) { staff }

      context 'entrando al formulario' do
        let(:staff2) { nil }
        it { is_expected.to permit_action(:new) }
      end

      context 'el usuario a crear es ejecutivo' do
        let(:staff2) { FactoryGirl.build(:staff, :executive, :branch_office_id => branch_office) }
        it { is_expected.to permit_action(:create) }
      end

      context 'el usuario a crear es administrador' do
        let(:staff2) { FactoryGirl.build(:staff, :admin) }
        it { is_expected.to forbid_action(:create) }
      end

      context 'el usuario a crear es jefe de sucursal' do
        let(:staff2) { FactoryGirl.build(:staff, :manager, :branch_office_id => branch_office) }
        it { is_expected.to forbid_action(:create) }
      end

      context 'el usuario a crear es supervisor' do
        let(:staff2) { FactoryGirl.build(:staff, :supervisor, :branch_office_id => branch_office) }
        it { is_expected.to permit_action(:create) }
      end

      context 'el usuario a crear es de sucursal distinta que el jefe de sucursal que lo esta creando' do
        let(:staff2) { FactoryGirl.build(:staff, :executive, :branch_office_id => branch_office + 1) }
        it { is_expected.to forbid_action(:create) }
      end

    end

  end


  context 'modificando bloques horarios de un ejecutivo' do

    branch_office = FactoryGirl.create(:branch_office)

    # staff = el usuario logueado
    # staff2 = el usuario al cual se le esta modificando sus horarios

    context 'siendo un visitor (sin login)' do
      let(:staff) { nil }
      let(:staff2) { FactoryGirl.create(:staff, :executive) }
      it { is_expected.to forbid_action(:update_time_blocks) }
    end

    context 'siendo administrador' do
      let(:staff) { FactoryGirl.create(:staff, :admin) }
      let(:staff2) { FactoryGirl.create(:staff, :executive) }
      it { is_expected.to permit_action(:update_time_blocks) }
    end

    context 'siendo ejecutivo' do
      let(:staff) { FactoryGirl.create(:staff, :executive) }
      let(:staff2) { FactoryGirl.create(:staff, :executive) }
      it { is_expected.to forbid_action(:update_time_blocks) }
    end

    context 'siendo supervisor' do
      attention = FactoryGirl.create(:attention_type)
      supervisor = FactoryGirl.create(:staff, :supervisor, :branch_office => branch_office, :attention_type => attention)
      let(:staff) { supervisor }
      let(:staff2) { FactoryGirl.create(:staff, :executive, :branch_office => branch_office, :attention_type => attention) }
      it { is_expected.to permit_action(:update_time_blocks) }
    end

    context 'siendo jefe de sucursal' do
      attention = FactoryGirl.create(:attention_type)
      manager = FactoryGirl.create(:staff, :manager, :branch_office => branch_office)
      let(:staff) { manager }
      let(:staff2) { FactoryGirl.create(:staff, :executive, :branch_office => branch_office, :attention_type => attention) }
      it { is_expected.to permit_action(:update_time_blocks) }
    end

    context 'cuando el personal pertence a sucursal distinta prohibe la accion' do
      context 'siendo supervisor' do
        office1 = FactoryGirl.create(:branch_office)
        office2 = FactoryGirl.create(:branch_office)
        supervisor = FactoryGirl.create(:staff, :manager, :branch_office => office1)
        let(:staff) { supervisor }
        let(:staff2) { FactoryGirl.create(:staff, :executive) }
        it { is_expected.to forbid_action(:update_time_blocks) }
      end
      context 'siendo jefe de sucursal' do
        office1 = FactoryGirl.create(:branch_office)
        office2 = FactoryGirl.create(:branch_office)
        manager = FactoryGirl.create(:staff, :manager, :branch_office => office1)
        let(:staff) { manager }
        let(:staff2) { FactoryGirl.create(:staff, :executive) }
        it { is_expected.to forbid_action(:update_time_blocks) }
      end
    end

  end



end
