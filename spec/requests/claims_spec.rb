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

    context 'with valid params' do
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

      it 'returns http not found' do
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
