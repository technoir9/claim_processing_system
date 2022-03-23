# frozen_string_literal: true

RSpec.describe Flight, type: :model do
  describe 'validations' do
    subject { build(:flight) }

    it { is_expected.to validate_presence_of(:airline_code) }
    it { is_expected.to validate_presence_of(:arrival_airport_code) }
    it { is_expected.to validate_presence_of(:departure_airport_code) }
    it { is_expected.to validate_presence_of(:departure_date) }
    it { is_expected.to validate_presence_of(:flight_number) }
  end
end
