# frozen_string_literal: true
require 'rails_helper'

RSpec.describe StudentsController, type: :controller do
  let(:group_a) { create :group, group_name: 'Group A' }

  context 'logged in as a global administrator' do
    let(:organization) { create :organization }
    let(:signed_in_user) { create :admin }
    before :each do
      sign_in signed_in_user
    end

    describe '#create' do
      it 'creates a student when supplied valid params' do
        post :create, params: { student: {
          mlid: '1M',
          first_name: 'Trevor',
          last_name: 'Noah',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
          group_id: group_a.id,
          gender: 'M',
          organization_id: organization.id,
          quartier: 'He lives somewhere...',
          estimated_dob: true
        } }
        expect(response).to redirect_to student_path(assigns[:student])

        student = Student.last
        expect(student.first_name).to eql 'Trevor'
        expect(student.last_name).to eql 'Noah'
        expect(student.group.group_name).to eql 'Group A'
        expect(student.gender).to eql 'M'
        expect(student.quartier).to eql 'He lives somewhere...'
      end

      it 'creates a female student when supplied valid params' do
        post :create, params: { student: {
          mlid: '1F',
          first_name: 'Ami',
          last_name: 'Ayola',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
          gender: 'F',
          organization_id: organization.id,
          estimated_dob: true
        } }
        student = Student.last
        expect(student.first_name).to eql 'Ami'
        expect(student.last_name).to eql 'Ayola'
        expect(student.gender).to eql 'F'
      end

      it 'creates a student with guardian inormation' do
        post :create, params: { student: {
          mlid: '1G',
          first_name: 'Guardianed',
          last_name: 'Guard',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
          gender: 'F',
          organization_id: organization.id,
          guardian_name: 'Guardian Omonzu',
          guardian_occupation: 'Moto driver',
          guardian_contact: '123-123-123 or email@example.com',
          family_members: 'Brothers: Omonu and Umunzu'
        } }
        student = Student.last
        expect(student.first_name).to eql 'Guardianed'
        expect(student.last_name).to eql 'Guard'
        expect(student.guardian_name).to eql 'Guardian Omonzu'
        expect(student.guardian_occupation).to eql 'Moto driver'
        expect(student.guardian_contact).to eql '123-123-123 or email@example.com'
        expect(student.family_members).to eql 'Brothers: Omonu and Umunzu'
      end

      it 'creates a student with health information' do
        post :create, params: { student: {
          mlid: '1H',
          first_name: 'Healthy',
          last_name: 'Health',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
          gender: 'F',
          organization_id: organization.id,
          estimated_dob: true,
          health_insurance: 'HEALTH123',
          health_issues: 'In perfect health',
          hiv_tested: true
        } }
        student = Student.last
        expect(student.first_name).to eql 'Healthy'
        expect(student.last_name).to eql 'Health'
        expect(student.health_insurance).to eql 'HEALTH123'
        expect(student.health_issues).to eql 'In perfect health'
        expect(student.hiv_tested).to eql true
      end

      it 'creates a student with school information' do
        post :create, params: { student: {
          mlid: '1E',
          first_name: 'Educated',
          last_name: 'Dropout',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
          gender: 'F',
          organization_id: organization.id,
          name_of_school: 'Super School',
          school_level_completed: 'B2-1',
          year_of_dropout: 1995,
          reason_for_leaving: 'Financial situation'
        } }
        student = Student.last
        expect(student.first_name).to eql 'Educated'
        expect(student.last_name).to eql 'Dropout'
        expect(student.name_of_school).to eql 'Super School'
        expect(student.school_level_completed).to eql 'B2-1'
        expect(student.year_of_dropout).to eql 1995
        expect(student.reason_for_leaving).to eql 'Financial situation'
      end

      it 'creates a student with notes' do
        post :create, params: { student: {
          mlid: '1P',
          first_name: 'Prime',
          last_name: 'Noted',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
          gender: 'F',
          organization_id: organization.id,
          notes: 'Prime is showing great promise despite the initial learning difficulties.'
        } }
        student = Student.last
        expect(student.first_name).to eql 'Prime'
        expect(student.last_name).to eql 'Noted'
        expect(student.notes).to eql 'Prime is showing great promise despite the initial learning difficulties.'
      end
    end

    describe '#index' do
      before :each do
        @student1 = create :student
        @student2 = create :student
        @deleted_student = create :student, deleted_at: Time.zone.now

        get :index
      end

      it { should respond_with 200 }

      it 'gets a list of students' do
        expect(assigns(:students)).to include @student1
        expect(assigns(:students)).to include @student2
      end

      it 'does not display deleted students' do
        expect(assigns(:students)).not_to include @deleted_student
      end
    end

    describe '#destroy' do
      before :each do
        @student = create :student

        post :destroy, params: { id: @student.id }
      end

      it { should redirect_to students_path }
      it { should set_flash[:notice].to "Student \"#{@student.proper_name}\" successfully deleted." }

      it 'Marks the student as deleted' do
        expect(@student.reload.deleted_at).not_to be_nil
      end
    end

    describe 'grading' do
      before :each do
        group = create :group, group_name: 'Student Grades Spec Group'
        @student = create :student, first_name: 'Graden', last_name: 'Gradanovic', group: group
        sub = create :subject, subject_name: 'Student Grades Testing'
        @skill = create :skill_in_subject, skill_name: 'Controller Test I', subject: sub
        @lesson = create :lesson, subject: sub, group: group
        @gd1 = create :grade_descriptor, mark: 1, grade_description: 'Mark One For Skill One', skill: @skill
        @gd2 = create :grade_descriptor, mark: 2, grade_description: 'Mark Two For Skill One', skill: @skill
      end

      describe '#grades' do
        before :each do
          get :grades, params: { id: @student.id, lesson_id: @lesson.id }
        end

        it { should respond_with 200 }
        it { should render_template 'grades' }
      end

      describe '#grade' do
        before :each do
          post :grade, params: { id: @student.id, lesson_id: @lesson.id, student: {
            grades_attributes: { '0' => { grade_descriptor_id: @gd1.id } }
          } }
        end

        context 'successfully' do
          it { should redirect_to action: :grades }

          it 'Saves the new grade' do
            expect(@student.grades.length).to eq 1
            expect(@student.grades[0].grade_descriptor).to eq @gd1
          end

          it 'Updates the existing grade' do
            existing_grade_id = @student.grades[0].id
            post :grade, params: { id: @student.id, lesson_id: @lesson.id, student: {
              grades_attributes: { '0' => { id: existing_grade_id, grade_descriptor_id: @gd2.id } }
            } }

            student = Student.find @student.id
            expect(student.grades.length).to eq 1
            expect(student.grades[0].grade_descriptor).to eq @gd2
          end

          it 'Updates the existing grade to be ungraded' do
            existing_grade_id = @student.grades[0].id

            post :grade, params: { id: @student.id, lesson_id: @lesson.id, student: {
              grades_attributes: { '0' => { id: existing_grade_id, grade_descriptor_id: '' } }
            } }

            student = Student.find @student.id
            expect(student.grades.exclude_deleted.length).to eq 0
          end
        end
      end
    end
  end

  context 'logged in as a local administrator' do
    let(:organization1) { create :organization }
    let(:organization2) { create :organization }
    let(:signed_in_user) { create :admin_of, organization: organization1 }

    before :each do
      sign_in signed_in_user
    end

    describe '#index' do
      it 'gets a list of students only bellonging to the signed in user\'s organization' do
        student1 = create :student, organization: organization1
        student2 = create :student, organization: organization1
        student3 = create :student, organization: organization2

        get :index
        expect(response).to be_success
        expect(assigns(:students).length).to eq 2
        expect(assigns(:students)).to include student1
        expect(assigns(:students)).to include student2
        expect(assigns(:students)).to_not include student3
      end
    end
  end
end
