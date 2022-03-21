# frozen_string_literal: true

RSpec.describe 'Claims', type: :request do
  describe 'POST #create' do
    subject { post '/claims', params: claim_params }

    let(:claim_params) do
      {
        customer_attributes: {
          first_name: 'John',
          last_name: 'Snow',
          email: 'john.snow@omlet.pl'
        },
        flights_attributes: [
          {
            departure_airport_code: 'KRK',
            arrival_airport_code: 'WAW',
            flight_number: '1234',
            airline_code: 'LO',
            departure_date: '2022-03-19'
          },
          {
            departure_airport_code: 'WAW',
            arrival_airport_code: 'GDN',
            flight_number: '3454',
            airline_code: 'FR',
            departure_date: '2021-01-02'
          }
        ]
      }
    end
    let(:status_code) { 200 }
    let(:stubbed_response) do
      {
        'id' => '1',
        'claim_id' => '123',
        'requester' => 'some github user'
      }.to_json
    end

    before do
      stub_request(:post, "#{ENV.fetch('CLAIM_API_URL')}/claim_notifications")
        .to_return(status: status_code, body: stubbed_response, headers: {})
    end

    context 'with valid params' do
      let(:stubbed_response2) do
        [{
          'flight_identifier' => 'OS-411-20211024-VIE-CDG',
          'airline_code' => 'OS',
          'flight_number' => '411',
          'departure_date' => '2021-10-24',
          'departure_airport_code' => 'VIE',
          'arrival_airport_code' => 'CDG',
          'delay_mins' => nil,
          'flight_status' => flight_status
        }].to_json
      end
      let(:flight_status) { 'on_time' }
      let(:status_code2) { 200 }
      let(:flight_identifier1) { 'LO-1234-20220319-KRK-WAW' }
      let(:flight_identifier2) { 'FR-3454-20210102-WAW-GDN' }

      before do
        stub_request(:get, "#{ENV.fetch('CLAIM_API_URL')}/flights?flight_identifier=#{flight_identifier1}")
          .to_return(status: status_code2, body: stubbed_response2, headers: {})
        stub_request(:get, "#{ENV.fetch('CLAIM_API_URL')}/flights?flight_identifier=#{flight_identifier2}")
          .to_return(status: status_code2, body: stubbed_response2, headers: {})
      end

      it 'returns http success' do
        subject

        expect(response).to have_http_status(:success)
      end

      it 'returns empty response' do
        subject

        expect(response.body).to eq('')
      end

      it 'creates customer, claim and flights records' do
        expect { subject }.to change(Customer, :count).by(1) &
                              change(Claim, :count).by(1) &
                              change(Flight, :count).by(2)
      end

      it 'calls a worker' do
        expect(ClaimNotificationWorker).to receive(:perform_async)

        subject
      end

      context 'with eligible flights' do
        let(:flight_status) { 'cancelled' }

        it 'notifies about newly-created eligible claim' do
          expect(ClaimsApi::V1::Notifications).to receive(:new).and_call_original

          subject
        end
      end

      context 'with ineligible flights' do
        let(:flight_status) { 'no_data' }

        it 'does not notify about the claim' do
          expect(ClaimsApi::V1::Notifications).not_to receive(:new)

          subject
        end
      end
    end

    context 'without customer params' do
      let(:claim_params) do
        {
          flights_attributes: [
            {
              departure_airport_code: 'KRK',
              arrival_airport_code: 'WAW',
              flight_number: '1234',
              airline_code: 'LO',
              departure_date: '2022-03-19'
            },
            {
              departure_airport_code: 'WAW',
              arrival_airport_code: 'GDN',
              flight_number: '3454',
              airline_code: 'FR',
              departure_date: '2021-01-02'
            }
          ]
        }
      end

      it 'returns http 422' do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        subject

        expect(JSON.parse(response.body)).to eq(
          { 'error' => { 'customer' => ['must exist'] } }
        )
      end

      it 'does not create any records' do
        expect { subject }.to not_change(Customer, :count) &
                              not_change(Claim, :count) &
                              not_change(Flight, :count)
      end

      it 'does not call a worker' do
        expect(ClaimNotificationWorker).not_to receive(:perform_async)

        subject
      end
    end

    context 'without flight params' do
      let(:claim_params) do
        {
          customer_attributes: {
            first_name: 'John',
            last_name: 'Snow',
            email: 'john.snow@omlet.pl'
          },
          flights_attributes: []
        }
      end

      it 'returns http 422' do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        subject

        expect(JSON.parse(response.body)).to eq(
          { 'error' => 'Claim must have at least one flight' }
        )
      end

      it 'does not create any records' do
        expect { subject }.to not_change(Customer, :count) &
                              not_change(Claim, :count) &
                              not_change(Flight, :count)
      end

      it 'does not call a worker' do
        expect(ClaimNotificationWorker).not_to receive(:perform_async)

        subject
      end
    end

    context 'with invalid customer params' do
      let(:claim_params) do
        {
          customer_attributes: {
            first_name: 'John',
            email: 'john.snow@pl'
          },
          flights_attributes: [
            {
              departure_airport_code: 'KRK',
              arrival_airport_code: 'WAW',
              flight_number: '1234',
              airline_code: 'LO',
              departure_date: '2022-03-19'
            },
            {
              departure_airport_code: 'WAW',
              arrival_airport_code: 'GDN',
              flight_number: '3454',
              airline_code: 'FR',
              departure_date: '2021-01-02'
            }
          ]
        }
      end

      it 'returns http 422' do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        subject

        expect(JSON.parse(response.body)).to eq(
          { 'error' => { 'customer.email' => ['is invalid'] } }
        )
      end

      it 'does not create any records' do
        expect { subject }.to not_change(Customer, :count) &
                              not_change(Claim, :count) &
                              not_change(Flight, :count)
      end

      it 'does not call a worker' do
        expect(ClaimNotificationWorker).not_to receive(:perform_async)

        subject
      end
    end

    context 'with invalid flight params' do
      let(:claim_params) do
        {
          customer_attributes: {
            first_name: 'John',
            last_name: 'Snow',
            email: 'john.snow@omlet.pl'
          },
          flights_attributes: [
            {
              departure_airport_code: 'KRK',
              arrival_airport_code: 'WAW',
              flight_number: '1234'
            },
            {
              flight_number: '3454',
              airline_code: 'FR',
              departure_date: '2021-01-02'
            }
          ]
        }
      end
      let(:expected_response) do
        {
          'error' => {
            'flights.airline_code' => ["can't be blank"],
            'flights.arrival_airport_code' => ["can't be blank"],
            'flights.departure_airport_code' => ["can't be blank"],
            'flights.departure_date' => ["can't be blank"]
          }
        }
      end

      it 'returns http 422' do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        subject

        expect(JSON.parse(response.body)).to eq(expected_response)
      end

      it 'does not create any records' do
        expect { subject }.to not_change(Customer, :count) &
                              not_change(Claim, :count) &
                              not_change(Flight, :count)
      end

      it 'does not call a worker' do
        expect(ClaimNotificationWorker).not_to receive(:perform_async)

        subject
      end
    end
  end

  describe 'GET #show' do
    subject { get "/claims/#{claim_id}" }

    let(:claim) { create(:claim) }
    let(:claim_id) { claim.id }
    let!(:flight1) { create(:flight, claim: claim) }
    let!(:flight2) { create(:flight, claim: claim) }
    let(:expected_response) do
      {
        'id' => claim_id,
        'customer' => {
          'id' => claim.customer.id,
          'first_name' => claim.customer.first_name,
          'last_name' => claim.customer.last_name,
          'email' => claim.customer.email
        },
        'flights' => match_array([
          {
            'id' => flight1.id,
            'departure_airport_code' => flight1.departure_airport_code,
            'arrival_airport_code' => flight1.arrival_airport_code,
            'airline_code' => flight1.airline_code,
            'flight_number' => flight1.flight_number,
            'departure_date' => flight1.departure_date.to_s
          },
          {
            'id' => flight2.id,
            'departure_airport_code' => flight2.departure_airport_code,
            'arrival_airport_code' => flight2.arrival_airport_code,
            'airline_code' => flight2.airline_code,
            'flight_number' => flight2.flight_number,
            'departure_date' => flight2.departure_date.to_s
          }
        ])
      }
    end

    context 'when claim exists' do
      it 'returns http success' do
        subject

        expect(response).to have_http_status(:success)
      end

      it 'returns claim data' do
        subject

        expect(JSON.parse(response.body)).to match(expected_response)
      end
    end

    context "when claim doesn't exist" do
      let(:claim_id) { claim.id + 1000 }

      it 'returns http 404' do
        subject

        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message' do
        subject

        expect(JSON.parse(response.body)).to eq(
          { 'error' => 'Record not found' }
        )
      end
    end
  end

  describe 'GET #eligibility' do
    subject { get "/claims/#{claim_id}/eligibility" }

    let(:claim) { create(:claim) }
    let(:claim_id) { claim.id }
    let!(:flight) { create(:flight, claim: claim) }
    let(:stubbed_response) do
      [{
        'flight_identifier' => 'OS-411-20211024-VIE-CDG',
        'airline_code' => 'OS',
        'flight_number' => '411',
        'departure_date' => '2021-10-24',
        'departure_airport_code' => 'VIE',
        'arrival_airport_code' => 'CDG',
        'delay_mins' => delay_mins,
        'flight_status' => flight_status
      }].to_json
    end
    let(:delay_mins) { nil }
    let(:flight_status) { 'cancelled' }
    let(:status_code) { 200 }

    before do
      stub_request(:get, "#{ENV.fetch('CLAIM_API_URL')}/flights?flight_identifier=#{flight.identifier}")
        .to_return(status: status_code, body: stubbed_response, headers: {})
    end

    shared_examples 'eligible claim' do
      let(:expected_response) do
        {
          'eligible' => true
        }
      end

      it 'returns http 200' do
        subject

        expect(response).to have_http_status(:ok)
      end

      it 'returns claim data' do
        subject

        expect(JSON.parse(response.body)).to match(expected_response)
      end
    end

    shared_examples 'ineligible claim' do
      let(:expected_response) do
        {
          'eligible' => false
        }
      end

      it 'returns http 200' do
        subject

        expect(response).to have_http_status(:ok)
      end

      it 'returns claim data' do
        subject

        expect(JSON.parse(response.body)).to match(expected_response)
      end
    end

    context 'when claim exists' do
      context 'with a cancelled flight' do
        let(:flight_status) { 'cancelled' }

        include_examples 'eligible claim'
      end

      context 'with a delayed flight' do
        let(:flight_status) { 'delayed' }

        context 'by more than 180 minutes' do
          let(:delay_mins) { 181 }

          include_examples 'eligible claim'
        end

        context 'by no more than 180 minutes' do
          let(:delay_mins) { 180 }

          include_examples 'ineligible claim'
        end
      end

      context 'with an on-time flight' do
        let(:flight_status) { 'on_time' }

        include_examples 'ineligible claim'
      end

      context 'without flight status data' do
        let(:flight_status) { 'no_data' }

        include_examples 'ineligible claim'
      end
    end

    context 'when API returns 404' do
      let(:status_code) { 404 }

      it 'returns http 404' do
        subject

        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message' do
        subject

        expect(JSON.parse(response.body)).to eq(
          { 'error' => 'Record not found' }
        )
      end
    end

    context 'when API returns 4xx, but not 404' do
      let(:status_code) { 400 }
      let(:stubbed_response) { 'Some client error message' }

      it 'returns http 400' do
        subject

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error message' do
        subject

        expect(JSON.parse(response.body)).to eq(
          { 'error' => 'Some client error message' }
        )
      end
    end

    context 'when API returns 5xx' do
      let(:status_code) { 500 }

      it 'returns http 500' do
        subject

        expect(response).to have_http_status(:internal_server_error)
      end

      it 'returns error message' do
        subject

        expect(JSON.parse(response.body)).to eq(
          { 'error' => 'Internal server error' }
        )
      end
    end

    context "when claim doesn't exist" do
      let(:claim_id) { claim.id + 1000 }

      it 'returns http 404' do
        subject

        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message' do
        subject

        expect(JSON.parse(response.body)).to eq(
          { 'error' => 'Record not found' }
        )
      end
    end
  end
end
