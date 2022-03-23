# frozen_string_literal: true

require 'csv'

module Csv
  class Generate
    extend Dry::Initializer

    param :headers, Dry.Types::Array.of(Dry.Types::String), reader: :private
    param :rows, Dry.Types::Array.of(Dry.Types::Array), reader: :private

    def call
      CSV.generate(headers: true) do |csv|
        csv << headers
        rows.each do |row|
          csv << row
        end
      end
    end
  end
end
