class SettingPolicy < ApplicationPolicy

  def index?
    onlyAdmin
  end

  def show?
    onlyAdmin
  end

  def create?
    onlyAdmin
  end

  def new?
    onlyAdmin
  end

  def update?
    onlyAdmin
  end

  def edit?
    onlyAdmin
  end

  def destroy?
    onlyAdmin
  end

  private
  def onlyAdmin
    user != nil && user.admin?
  end

end
