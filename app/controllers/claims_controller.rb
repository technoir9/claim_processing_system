# frozen_string_literal: true

class ClaimsController < ApplicationController
  def create
    result = Claims::Create.new(create_claim_params.to_h).call

    if result.success?
      head 204
    else
      render json: { error: result.failure }, status: :unprocessable_entity
    end
  end

  def show
    render json: ClaimRepresenter.new(claim)
  end

  private

  def create_claim_params
    params.permit(
      customer_attributes: [:first_name, :last_name, :email],
      flights_attributes: [:departure_airport_code, :arrival_airport_code, :flight_number, :airline_code, :departure_date]
    )
  end

  def claim
    Claim.find(params.require(:id))
  end
end
