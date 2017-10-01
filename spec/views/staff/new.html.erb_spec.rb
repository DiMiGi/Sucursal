require 'rails_helper'

describe 'staff/new.html.erb' do
  context 'sesion iniciada como jefe de sucursal' do
    it 'asigna sucursal automaticamente (no da para escoger)' do
      sign_in FactoryGirl.create(:staff, :manager)
      assign(:staff, nil)
      render
      expect(rendered).to have_text 'El nuevo usuario sera asignado'
    end
  end

  context 'sesion iniciada como administrador' do
    it 'muestra un selector para escoger sucursal' do
      sign_in FactoryGirl.create(:staff, :admin)
      assign(:staff, nil)
      render
      expect(rendered).to have_selector("div", :id => "branch-office-list-by-location")
    end
  end


end
