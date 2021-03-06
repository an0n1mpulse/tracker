# frozen_string_literal: true

class SkillPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    super || (user_org_ids & record.subjects.pluck(:organization_id)).present?
  end

  def new?
    create?
  end

  def create?
    user.administrator? record.organization
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user.global_role?

      scope.joins('LEFT JOIN assignments on skill_id = skills.id LEFT JOIN subjects on subject_id = subjects.id')
           .where('skills.organization_id IN (:org_ids) OR subjects.organization_id IN (:org_ids)', org_ids: user.roles.pluck(:resource_id))
    end
  end
end
