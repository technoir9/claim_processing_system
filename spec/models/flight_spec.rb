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

  describe '#identifier' do
    subject { flight.identifier }

    let(:flight) do
      build(:flight, airline_code: 'SK',
                     arrival_airport_code: 'ARN',
                     departure_airport_code: 'MAN',
                     departure_date: '2020-12-28',
                     flight_number: '2550')
    end

    it 'returns flight identifier' do
      expect(subject).to eq('SK-2550-20201228-MAN-ARN')
    end
  end
end
