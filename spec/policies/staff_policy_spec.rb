require 'rails_helper'

describe StaffPolicy do

  subject { StaffPolicy.new(staff, newStaff) }

  context 'crear usuario siendo un visitor (sin login)' do
    let(:staff) { nil }
    let(:newStaff) { nil }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'crear usuario siendo un ejecutivo' do
    let(:staff) { FactoryGirl.build(:staff, :executive) }
    let(:newStaff) { nil }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'crear usuario siendo un supervisor' do
    let(:staff) { FactoryGirl.build(:staff, :supervisor) }
    let(:newStaff) { nil }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'crear usuario siendo un administrador' do
    let(:staff) { FactoryGirl.build(:staff, :admin) }
    let(:newStaff) { FactoryGirl.build(:staff) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
  end


  context 'crear usuario siendo un jefe de sucursal' do

    # Primero verificar si puede entrar a la pagina del formulario
    staff = FactoryGirl.create(:staff, :manager)
    branch_office = staff.branch_office_id
    let(:staff) { staff }

    context 'entrando al formulario' do
      let(:newStaff) { nil }
      it { is_expected.to permit_action(:new) }
    end

    context 'el usuario a crear es ejecutivo' do
      let(:newStaff) { FactoryGirl.build(:staff, :executive, :branch_office_id => branch_office) }
      it { is_expected.to permit_action(:create) }
    end

    context 'el usuario a crear es administrador' do
      let(:newStaff) { FactoryGirl.build(:staff, :admin) }
      it { is_expected.to forbid_action(:create) }
    end

    context 'el usuario a crear es jefe de sucursal' do
      let(:newStaff) { FactoryGirl.build(:staff, :manager, :branch_office_id => branch_office) }
      it { is_expected.to forbid_action(:create) }
    end

    context 'el usuario a crear es supervisor' do
      let(:newStaff) { FactoryGirl.build(:staff, :supervisor, :branch_office_id => branch_office) }
      it { is_expected.to permit_action(:create) }
    end

    context 'el usuario a crear es de sucursal distinta que el jefe de sucursal que lo esta creando' do
      let(:newStaff) { FactoryGirl.build(:staff, :executive, :branch_office_id => branch_office + 1) }
      it { is_expected.to forbid_action(:create) }
    end

  end

end
