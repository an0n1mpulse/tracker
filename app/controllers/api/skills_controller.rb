# frozen_string_literal: true
module Api
  class SkillsController < ApiController
    has_scope :after_timestamp
    has_scope :by_organization, as: :organization_id
    has_scope :by_subject, as: :subject_id

    def index
      @skills = apply_scopes(Skill).all
      respond_with @skills, status: :ok, meta: { timestamp: Time.zone.now }
    end

    def show
      @skill = Skill.find params.require(:id)
      respond_with @skill, status: :ok, meta: { timestamp: Time.zone.now }
    end
  end
end
