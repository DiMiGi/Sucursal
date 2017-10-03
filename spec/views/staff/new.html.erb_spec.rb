require 'rails_helper'

describe 'staff/new.html.erb' do
  context 'sesion iniciada como jefe de sucursal' do
    it 'asigna sucursal automaticamente (no da para escoger)' do
      sign_in FactoryGirl.create(:manager)
      assign(:staff, nil)
      render
      expect(rendered).to have_text 'El nuevo usuario sera asignado'
    end
  end

  context 'sesion iniciada como administrador' do

    pending 'Falta verificar con Capybara que el usuario se agregue al presionar el boton'

    before(:each) do # Iniciar sesion
      @admin = FactoryGirl.create(:admin)
      visit root_path
      within("#new_staff") do
        fill_in 'Email', :with => @admin.email
        fill_in 'Password', :with => @admin.password
        find('input[type=submit]').click
      end
    end

    it 'muestra un selector para escoger sucursal' do
      visit new_staff_path
      expect(page).to have_selector("div", :id => "branch-office-list-by-location")
    end

    it 'puede crear un usuario correctamente' do
      visit new_staff_path
      within("#new-user-form") do
        fill_in 'Nombres', :with => 'Carlitros'
        fill_in 'Primer apellido', :with => 'Vilchuka'
        fill_in 'E-mail', :with => 'carlitros@vilchuka.es'
        fill_in 'Contraseña', :with => '123456789'
        fill_in 'Confirmar contraseña', :with => '123456789'
        find('button[type=submit]').click
      end

    end

  end

end
