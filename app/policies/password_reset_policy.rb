# frozen_string_literal: true

class PasswordResetPolicy < ApplicationPolicy
  def show?
    user.is_anonymous?
  end

  def create?
    user.is_anonymous?
  end

  def update?
    user.is_anonymous?
  end
end
