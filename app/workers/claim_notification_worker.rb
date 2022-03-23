# frozen_string_literal: true

class ClaimNotificationWorker
  include Sidekiq::Worker

  def perform(claim_id)
    claim = Claim.find(claim_id)
    ClaimsApi::V1::Notifications.new(claim).call if eligible?(claim)
  end

  private

  def eligible?(claim)
    Claims::Eligibility.new(claim).call
  end
end
