class Skill < ApplicationRecord
  validates :skill_name, :organization, presence: true
  validate :grade_descriptors_must_have_unique_marks

  belongs_to :organization
  has_many :grade_descriptors, dependent: :destroy, inverse_of: :skill
  has_many :assignments, dependent: :destroy
  has_many :subjects, through: :assignments

  accepts_nested_attributes_for :grade_descriptors

  def grade_descriptors_must_have_unique_marks
    return if grade_descriptors.empty?
    return unless duplicates? grade_descriptors.map(&:mark)

    errors.add :grade_descriptors, 'Grade Descriptors cannot have duplicate marks.'
  end

  private

  def duplicates?(arr)
    arr.uniq.length != arr.length
  end
end