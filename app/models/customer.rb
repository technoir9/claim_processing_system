# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :flights, dependent: :destroy

  validates :email, presence: true, email: { mode: :strict, require_fqdn: true }
end
