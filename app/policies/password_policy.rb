# frozen_string_literal: true

class PasswordPolicy < ApplicationPolicy
  def update?
    record.id == user.id
  end
end
