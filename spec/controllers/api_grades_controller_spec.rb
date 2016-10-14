# rubocop:disable Style/VariableNumber
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::GradesController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:json_grade) { json['grade'] }
  let(:json_grades) { json['grades'] }

  before :each do
    @group = create :group
    @student = create :student, group: @group

    @subject = create :subject
    @skill1 = create :skill, subject: @subject
    @skill2 = create :skill, subject: @subject

    @gd1_1 = create :grade_descriptor, mark: 1, skill: @skill1
    @gd1_2 = create :grade_descriptor, mark: 2, skill: @skill1
    @gd2_1 = create :grade_descriptor, mark: 1, skill: @skill2
    @gd2_2 = create :grade_descriptor, mark: 2, skill: @skill2

    @lesson = create :lesson, group: @group, subject: @subject
  end

  describe '#index' do
    before :each do
      @lesson1 = create :lesson
      @lesson2 = create :lesson

      @grade1 = create :grade, student: @student, lesson: @lesson1, created_at: 3.months.ago, updated_at: 3.months.ago
      @grade2 = create :grade, student: @student, lesson: @lesson1, created_at: 3.months.ago, updated_at: 3.months.ago
      @grade3 = create :grade, lesson: @lesson2
      @grade4 = create :grade, lesson: @lesson2
      @grade5 = create :grade, lesson: @lesson2

      get :index, format: :json
    end

    it 'lists all grades' do
      expect(json_grades.length).to eq 5
      expect(json_grades.map { |g| g['id'] }).to include @grade1.id, @grade2.id, @grade3.id, @grade4.id, @grade5.id
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    it 'lists only grades scoped by student' do
      get :index, format: :json, params: { student_id: @student.id }

      expect(json_grades.length).to eq 2
      expect(json_grades.map { |g| g['id'] }).to include @grade1.id, @grade2.id
    end

    it 'lists only grades scoped by lesson' do
      get :index, format: :json, params: { lesson_id: @lesson2.id }

      expect(json_grades.length).to eq 3
      expect(json_grades.map { |g| g['id'] }).to include @grade3.id, @grade4.id, @grade5.id
    end

    it 'lists only grades create or updated after a certain time' do
      create :grade, created_at: 3.months.ago, updated_at: 3.months.ago
      create :grade, created_at: 2.months.ago, updated_at: 2.months.ago
      create :grade, created_at: 4.months.ago, updated_at: 3.months.ago

      get :index, format: :json, params: { after_timestamp: 1.day.ago }

      expect(json_grades.length).to eq 3
    end
  end

  describe 'show' do
    before :each do
      @grade = create :grade
      get :show, format: :json, params: { id: @grade.id }
    end

    it { should respond_with 200 }
    it 'responds with the requested grade' do
      expect(json_grade['id']).to eq @grade.id
      expect(json_grade['grade_descriptor_id']).to eq @grade.grade_descriptor_id
      expect(json_grade['lesson_id']).to eq @grade.lesson_id
      expect(json_grade['student_id']).to eq @grade.student_id
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end
  end

  describe 'create' do
    before :each do
      post :create, format: :json, params: { grade_descriptor_id: @gd1_1.id, lesson_id: @lesson.id, student_id: @student.id }
    end
    it { should respond_with 201 }

    it 'creates a new grade' do
      g = Grade.last
      expect(g.grade_descriptor).to eq @gd1_1
      expect(g.lesson).to eq @lesson
      expect(g.student).to eq @student
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end
  end

  describe '#update' do
    before :each do
      @subject = create :subject
      @skill = create :skill, subject: @subject
      @lesson = create :lesson, subject: @subject
      @gd1 = create :grade_descriptor, mark: 1, skill: @skill
      @gd2 = create :grade_descriptor, mark: 2, skill: @skill

      @grade = create :grade, grade_descriptor: @gd1, lesson: @lesson
    end

    it 'updates the grade\'s grade descriptor' do
      patch :update, format: :json, params: { id: @grade.id, grade_descriptor_id: @gd2.id }

      expect(@grade.reload.grade_descriptor).to eq @gd2
    end
  end

  describe '#destroy' do
    before :each do
      @grade = create :grade
      delete :destroy, format: :json, params: { id: @grade.id }
    end

    it { should respond_with 200 }
    it 'marks the grade as deleted' do
      expect(@grade.reload.deleted_at.nil?).to be false
    end
  end
end
