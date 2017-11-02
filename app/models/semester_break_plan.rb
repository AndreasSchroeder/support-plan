class SemesterBreakPlan < ApplicationRecord
  has_many :day_slots
  accepts_nested_attributes_for :day_slots
end
