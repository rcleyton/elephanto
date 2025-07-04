# typed: false
# frozen_string_literal: true

class PasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    validate_no_whitespace(record, attribute, value)
    validate_complexity(record, attribute, value)
  end

  private
  def validate_complexity(record, attribute, value)
    unless value.match?(/\A(?=.*[a-zA-Z])(?=.*\d)(?=.*[^a-zA-Z\d]).+\z/)
      record.errors.add(attribute, :password_not_complex)
    end
  end

  def validate_no_whitespace(record, attribute, value)
    if value.match?(/\s/)
      record.errors.add(attribute, :password_contains_whitespace)
    end
  end
end
