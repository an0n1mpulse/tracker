class SubjectsController < ApplicationController
  def index
    @subject = Subject.new
    @subjects = Subject.all
  end

  def create
    @subject = Subject.new subject_params
    return notice_and_redirect(t(:subject_created, subject: @subject.subject_name), subjects_url) if @subject.save
    render :index
  end

  private

  def subject_params
    params.require(:subject).permit :subject_name, :organization_id, assignments_attributes: [:id, :skill_id, :_destroy]
  end
end