# frozen_string_literal: true

RSpec.describe Customer, type: :model do
  describe 'validations' do
    subject { build(:customer, email: email) }

    context 'without email' do
      let(:email) { '' }

      it { is_expected.not_to be_valid }
    end

    context 'with invalid email' do
      let(:email) { 'invalid@email' }

      it { is_expected.not_to be_valid }
    end

    context 'with valid email' do
      let(:email) { 'user@example.com' }

      it { is_expected.to be_valid }
    end
  end
end
