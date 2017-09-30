class StaffPolicy < ApplicationPolicy

  def create?
    return false if user.nil?
    return true if user.admin?
    return false if record.nil?

    if(user.manager?)

      # Verifico que si el usuario que esta creando el usuario es un jefe de sucursal (manager),
      # entonces el usuario que esta creando es de esa misma sucursal.
      # Y que ademas, el tipo del usuario a crear sea de tipo ejecutivo o supervisor.
      return false if user.branch_office_id != record.branch_office_id     

      if record.position.to_sym == :supervisor || record.position.to_sym == :executive
        return true
      end
    end

    return false

  end

  def new?
    return false if user.nil?
    return true if user.admin?
    return true if user.manager?

    return false
  end

end
