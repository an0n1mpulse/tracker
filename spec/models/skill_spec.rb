# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Skill, type: :model do
  describe 'relationships' do
    it { should belong_to :organization }
    it { should have_many(:grade_descriptors).dependent :destroy }
    it { should have_many(:assignments).dependent :destroy }
    it { should have_many(:subjects).through :assignments }
  end

  describe 'validations' do
    it { should validate_presence_of :skill_name }
    it { should validate_presence_of :organization }

    describe 'validate grade descriptors' do
      let(:org) { create :organization }
      it 'is valid' do
        desc1 = GradeDescriptor.new mark: 1
        desc2 = GradeDescriptor.new mark: 2
        skill = Skill.new skill_name: 'Valid Skill', organization: org, grade_descriptors: [desc1, desc2]
        expect(skill).to be_valid
      end

      it 'is not valid because grade descriptors have duplicated marks in the same skill' do
        desc1 = GradeDescriptor.new mark: 1
        desc2 = GradeDescriptor.new mark: 1
        skill = Skill.new skill_name: 'Valid Skill', organization: org, grade_descriptors: [desc1, desc2]
        expect(skill).to be_invalid
      end

      it 'is not valid because grade descriptor is not valid' do
        desc = GradeDescriptor.new
        skill = Skill.new skill_name: 'Valid Skill', organization: org, grade_descriptors: [desc]
        expect(skill).to be_invalid
      end
    end
  end

  describe 'scopes' do
    before :each do
      @subject = create :subject

      @org1 = create :organization
      @org2 = create :organization

      @skill1 = create :skill_in_subject, organization: @org1, subject: @subject
      @skill2 = create :skill, organization: @org1
      @skill3 = create :skill, organization: @org2
    end

    describe 'by_organization' do
      it 'returns skills scoped by organization' do
        expect(Skill.by_organization(@org1.id).length).to eq 2
        expect(Skill.by_organization(@org1.id)).to include @skill1, @skill2
      end
    end

    describe 'by_subject' do
      it 'returns skills scoped by subject' do
        expect(Skill.by_subject(@subject.id).length).to eq 1
        expect(Skill.by_subject(@subject.id)).to include @skill1
      end
    end
  end
end
