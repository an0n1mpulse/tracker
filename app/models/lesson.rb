class Lesson < ApplicationRecord
  validates :group, :date, :subject, presence: true
  validates :date, uniqueness: {
    scope: [:group, :subject],
    message: ->(object, _data) { I18n.translate :duplicate_lesson, group: object.group.group_name, subject: object.subject.subject_name }
  }

  belongs_to :group
  belongs_to :subject
end