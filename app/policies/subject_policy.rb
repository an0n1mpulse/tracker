# frozen_string_literal: true

class SubjectPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    user.administrator? record.organization
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user.global_role?

      scope.where(organization_id: user.roles.pluck(:resource_id))
    end
  end
end
