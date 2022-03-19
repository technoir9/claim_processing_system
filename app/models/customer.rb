# frozen_string_literal: true

class Customer < ApplicationRecord
  validates :email, presence: true, email: { mode: :strict, require_fqdn: true }
end
