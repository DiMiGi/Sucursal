module ApplicationHelper

  # Esto es para solucionar un problema al testear formularios de Devise
  # https://stackoverflow.com/questions/37452267/undefined-local-variable-resource-in-devise-4-1-and-rails-5-0-0-rc1

  def resource_name
    :staff
  end

  def resource
    @resource ||= Staff.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:staff]
  end

end
