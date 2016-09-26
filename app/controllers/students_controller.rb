class StudentsController < ApplicationController
  def index
    @students = policy_scope Student
  end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new student_params
    return notice_and_redirect t(:student_created, name: @student.proper_name), @student if @student.save
    render :new
  end

  def show
    @student = Student.find params[:id]
  end

  def edit
    @student = Student.find params[:id]
  end

  def update
    @student = Student.find params[:id]
    return redirect_to @student if @student.update_attributes student_params

    render :edit
  end

  def grade
    @student = Student.find params[:id]
    @skills = Lesson.find(params[:lesson_id]).subject.skills
  end

  private

  def student_params
    params.require(:student).permit(*Student.permitted_params)
  end
end
