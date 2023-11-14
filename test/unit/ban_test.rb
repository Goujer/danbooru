require 'test_helper'

class BanTest < ActiveSupport::TestCase
  context "A ban" do
    context "created by an admin" do
      setup do
        @banner = FactoryBot.create(:admin_user)
        CurrentUser.user = @banner
      end

      teardown do
        @banner = nil
        CurrentUser.user = nil
      end

      should "set the is_banned flag on the user" do
        user = FactoryBot.create(:user)
        ban = FactoryBot.build(:ban, :user => user, :banner => @banner)
        ban.save
        user.reload
        assert(user.is_banned?)
      end

      should "be valid" do
        user = FactoryBot.create(:user)
        ban = FactoryBot.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)
      end
    end

    should "initialize the expiration date" do
      user = FactoryBot.create(:user)
      admin = FactoryBot.create(:admin_user)
      CurrentUser.scoped(admin) do
        ban = FactoryBot.create(:ban, :user => user, :banner => admin)
        assert_not_nil(ban.expires_at)
      end
    end

    should "update the user's feedback" do
      user = create(:user)
      ban = create(:ban, user: user, duration: 100.years, reason: "lol")

      assert_equal(1, user.feedback.negative.count)
      assert_equal("Banned forever: lol", user.feedback.last.body)
    end

    should "send the user a dmail" do
      user = create(:user)
      ban = create(:ban, user: user, duration: 100.years, reason: "lol")

      assert_equal(1, user.dmails.count)
      assert_equal("You have been banned", user.dmails.last.title)
      assert_equal("You have been banned forever: lol", user.dmails.last.body)
    end
  end

  context "Searching for a ban" do
    should "find a given ban" do
      ban = create(:ban)

      assert_search_equals(ban, user_name: ban.user.name, banner_name: ban.banner.name, reason: ban.reason, expired: false, order: :id_desc)
    end

    context "by user id" do
      setup do
        @admin = FactoryBot.create(:admin_user)
        CurrentUser.user = @admin
        @user = FactoryBot.create(:user)
      end

      teardown do
        CurrentUser.user = nil
      end
    end
  end
end
