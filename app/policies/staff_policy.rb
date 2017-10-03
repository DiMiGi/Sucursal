class StaffPolicy < ApplicationPolicy

  def create?
    return false if user.nil?
    return true if user.admin?
    return false if record.nil?

    if(user.manager?)

      # Verifico que si el usuario que esta creando el usuario es un jefe de sucursal (manager),
      # entonces el usuario que esta creando es de esa misma sucursal.
      # Y que ademas, el tipo del usuario a crear sea de tipo ejecutivo o supervisor.
      return false if user.branch_office_id.nil?
      return false if user.branch_office_id != record.branch_office_id

      if record.supervisor? || record.executive?
        return true
      end
    end

    return false

  end

  def update_time_blocks?
    return false if user.nil?
    return true if user.admin?
    return false if record.nil?
    return false if !record.executive?
    return false if user.executive?

    if user.branch_office_id == record.branch_office_id && user.attention_type_id == record.attention_type_id
      return false if user.attention_type_id.nil?
      return false if user.branch_office_id.nil?
      return true if user.supervisor?
    end

    return true if user.manager? && user.branch_office_id == record.branch_office_id && !user.branch_office_id.nil?

    return false
  end

  def new?
    return false if user.nil?
    return true if user.admin?
    return true if user.manager?

    return false
  end

end
