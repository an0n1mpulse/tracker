require 'rails_helper'

RSpec.describe 'User interacts with lessons' do
  context 'As a global administrator' do
    include_context 'login_with_admin'

    it 'creates a lesson' do
      create :group, group_name: 'Lesson Group'
      create :subject, subject_name: 'Feature Testing I'

      visit '/'
      click_link 'Lessons'

      select 'Lesson Group', from: 'lesson_group_id'
      select 'Feature Testing I', from: 'lesson_subject_id'
      click_button 'Create'

      expect(page).to have_content 'Lesson successfully created'
    end

    it 'lists all existing lessons' do
      sub = create :subject, subject_name: 'Feature Testing II'
      create :lesson, subject: sub
      create :lesson, subject: sub

      visit '/'
      click_link 'Lessons'

      expect(page).to have_css '.lesson-row', count: 2
      expect(page).to have_content 'Feature Testing II'
    end

    it 'shows a specific lesson' do
      group = create :group, group_name: 'Lesson Feature Test Group'
      create :student, first_name: 'Marinko', last_name: 'Marinkovic', group: group
      create :student, first_name: 'Ivan', last_name: 'Ivankovic', group: group
      sub = create :subject, subject_name: 'Feature Testing III'
      create :lesson, subject: sub, group: group

      visit '/'
      click_link 'Lessons'
      first('.lesson-row-link').click

      expect(page).to have_content 'Lesson Feature Test Group'
      expect(page).to have_content 'Students'
      expect(page).to have_content 'Marinko'
      expect(page).to have_content 'Ivan'
    end

    describe 'grading' do
      let(:group) { create :group, group_name: 'Lesson Feature Test Group' }
      let(:subject) { create :subject, subject_name: 'Feature Testing III' }

      before :each do
        create :student, first_name: 'Graden', last_name: 'Gradanovic', group: group
        skill1 = create :skill_in_subject, skill_name: 'Featuring', subject: subject
        skill2 = create :skill_in_subject, skill_name: 'Testing', subject: subject

        create :grade_descriptor, mark: 1, grade_description: 'Mark One For Skill One', skill: skill1
        create :grade_descriptor, mark: 2, grade_description: 'Mark Two For Skill One', skill: skill1
        create :grade_descriptor, mark: 1, grade_description: 'Mark One For Skill Two', skill: skill2
        create :grade_descriptor, mark: 2, grade_description: 'Mark Two For Skill Two', skill: skill2

        @lesson = create :lesson, subject: subject, group: group
      end

      it 'shows students grades in specific lesson' do
        visit "/lessons/#{@lesson.id}"
        click_link 'Graden'

        expect(page).to have_content 'Graden'
        expect(page).to have_content 'Featuring'
        expect(page).to have_content 'Testing'
        expect(page).to have_content 'No Grade'
      end

      it 'grades a student' do
        visit "/lessons/#{@lesson.id}"
        click_link 'Graden'

        select '2 - Mark Two For Skill One', from: 'Featuring'
        select '1 - Mark One For Skill Two', from: 'Testing'

        click_button 'Save Student Grades'

        expect(page).to have_content 'Student successfully graded.'
        expect(page).to have_content 'Featuring'
        expect(page).to have_content 'Mark Two For Skill One'
        expect(page).to have_content 'Testing'
        expect(page).to have_content 'Mark One For Skill Two'
      end
    end
  end
end