require 'rails_helper'

describe 'devise/sessions/new.html.erb' do

  it 'aparece el formulario para iniciar sesion' do
    assign(:new_staff_session, nil)
    render
    expect(rendered).to have_selector("input", :id => "staff_email")
    expect(rendered).to have_selector("input", :id => "staff_password")
    expect(rendered).to have_text 'Iniciar sesión'
  end

  it 'inicia sesion correctamente' do
    FactoryGirl.create(:supervisor, :email => 'user@factorygirl.com', :password => 'factory')
    visit root_path
    within("#new_staff") do
      fill_in 'Email', :with => 'user@factorygirl.com'
      fill_in 'Password', :with => 'factory'
      find('input[type=submit]').click
    end
    expect(page).to have_text 'Cerrar sesión'
  end

  it 'inicia sesion incorrectamente' do
    visit root_path
    within("#new_staff") do
      fill_in 'Email', :with => '111111user@factorygirl.com'
      fill_in 'Password', :with => '22222factory'
      find('input[type=submit]').click
    end
    expect(page).to have_text 'Iniciar sesión'
  end

end
