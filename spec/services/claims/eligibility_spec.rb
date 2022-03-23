# frozen_string_literal: true

RSpec.describe Claims::Eligibility do
  describe '#call' do
    subject { described_class.new(claim).call }

    let(:claim) { create(:claim, eligibility: eligibility) }
    let(:service_double) { instance_double(ClaimsApi::V1::Flights, call: result) }
    let(:result) do
      [{
        'flight_status' => 'cancelled'
      }]
    end

    before do
      create(:flight, claim: claim)
      allow(ClaimsApi::V1::Flights).to receive(:new).and_return(service_double)
    end

    context 'when eligibility is unknown' do
      let(:eligibility) { 'unknown' }

      context 'when API returns an eligible flight_status' do
        it { is_expected.to eq(true) }

        it 'calls ClaimsApi::V1::Flights' do
          expect(service_double).to receive(:call)

          subject
        end
      end

      context 'when API returns an ineligible flight_status' do
        let(:result) do
          [{
            'flight_status' => 'no_data'
          }]
        end

        it { is_expected.to eq(false) }

        it 'calls ClaimsApi::V1::Flights' do
          expect(service_double).to receive(:call)

          subject
        end
      end
    end

    context 'when claim is already eligibile' do
      let(:eligibility) { 'eligible' }

      it { is_expected.to eq(true) }

      it 'does not call ClaimsApi::V1::Flights' do
        expect(service_double).not_to receive(:call)

        subject
      end
    end

    context 'when claim is already ineligibile' do
      let(:eligibility) { 'ineligible' }

      it { is_expected.to eq(false) }

      it 'does not call ClaimsApi::V1::Flights' do
        expect(service_double).not_to receive(:call)

        subject
      end
    end
  end
end
