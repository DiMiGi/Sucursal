class BranchOfficePolicy < ApplicationPolicy

  def update_attention_types_estimations?

    return false if user.nil?
    return false if user.executive?
    return true if user.admin?

    if(user.supervisor? || user.manager?)
      return true if user.branch_office_id == record.id
    end

    return false
  end


end
