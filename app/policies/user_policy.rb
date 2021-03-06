# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.global_role? || users_in_same_org?
  end

  def create?
    user.global_administrator?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.all if user.global_role?

      scope.joins(:roles).where(roles: { resource_id: user.roles.pluck(:resource_id) }).distinct
    end
  end

  private

  def users_in_same_org?
    !(user.roles.pluck(:resource_id) & record.roles.pluck(:resource_id)).empty?
  end
end
