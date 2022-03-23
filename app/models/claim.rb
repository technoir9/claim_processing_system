# frozen_string_literal: true

class Claim < ApplicationRecord
  belongs_to :customer
  has_many :flights, dependent: :nullify

  accepts_nested_attributes_for :customer, :flights

  enum eligibility: { unknown: 0, eligible: 1, ineligible: 2 }
end
