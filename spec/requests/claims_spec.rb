# frozen_string_literal: true

RSpec.describe 'Claims', type: :request do
  describe 'POST #create' do
    subject { post '/claims', params: claim_params }

    let(:claim_params) do
      {
        customer: {
          first_name: 'John',
          last_name: 'Snow',
          email: 'john.snow@omlet.pl'
        },
        flights: [
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

    it 'returns http success' do
      subject

      expect(response).to have_http_status(:success)
    end

    it 'creates customer, claim and flights records' do
      expect { subject }.to change(Customer, :count).by(1) &
                            change(Claim, :count).by(1) &
                            change(Flight, :count).by(2)
    end
  end

  describe 'GET #show' do
    subject { get "/claims/#{claim_id}" }

    let(:claim) { create(:claim) }
    let(:claim_id) { claim.id }

    context 'when claim exists' do
      it 'returns http success' do
        subject

        expect(response).to have_http_status(:success)
      end
    end

    context "when claim doesn't exist" do
      it 'returns http not found' do
        subject

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
