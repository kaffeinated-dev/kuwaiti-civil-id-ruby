# frozen_string_literal: true

require_relative "kuwaiti_civil_id/version"

module KuwaitiCivilId
  class Error < StandardError; end
  class InvalidCivilIdError < Error; end

  class CivilIdValidator
    def self.valid?(id_number)
      return false unless id_number.to_s.match?(/\A\d{12}$\z/)

      digits = id_number.to_s.chars.map(&:to_i)
      checksum = digits.pop
      coefficients = [2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
      digits.zip(coefficients).sum { |d, c| d * c }
      calculated_checksum = 11 - (sum % 11)
      calculated_checksum == checksum
    end
  end

  class BirthdateExtractor
    def self.extract(id_number)
      raise InvalidCivilIdError unless CivilIdValidator.valid?(id_number)

      century = id_number[0].to_i
      year = id_number[1..2].to_i
      month = id_number[3..4].to_i
      day = id_number[5..6].to_i

      century_prefix = case century
                       when 2 then "19"
                       when 3 then "20"
                       else return nil
                       end

      year = "#{century_prefix}#{year}".to_i
      Date.new(year, month, day)
    end
  end
end
