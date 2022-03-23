# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :claims, dependent: :destroy

  validates :email, presence: true, email: { mode: :strict, require_fqdn: true }
end
