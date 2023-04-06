require "test_helper"

module Developers
  class SearchScoreTest < ActiveSupport::TestCase
    setup do
      # 0 baseline score
      @developer = developers(:one)
      @developer.bio = "X" * 51
      @developer.scheduling_link = nil
      @developer.profile_updated_at = 4.months.ago
      @developer.created_at = 2.weeks.ago
    end

    test "large boost for high response rate" do
      @developer.response_rate = HasBadges::HIGH_RESPONSE_RATE_CUTTOFF
      @developer.conversations_count = 1
      assert_equal 20, @developer.score_for(:response_rate)
    end

    test "large demotion for low response rate" do
      @developer.response_rate = HasBadges::LOW_RESPONSE_RATE_CUTTOFF
      @developer.conversations_count = 1
      assert_equal -20, @developer.score_for(:response_rate)
    end

    test "no change when no conversations" do
      @developer.response_rate = HasBadges::LOW_RESPONSE_RATE_CUTTOFF
      @developer.conversations_count = 0
      assert_equal 0, @developer.score_for(:response_rate)
    end

    test "large boost for a source contributor" do
      @developer.source_contributor = true
      assert_equal 20, @developer.score_for(:source_contributor?)
    end

    test "medium boost for a scheduling link" do
      @developer.scheduling_link = "savvycal.com"
      assert_equal 10, @developer.score_for(:scheduling_link?)
    end

    test "large boost for profile updated in last month" do
      @developer.profile_updated_at = 3.weeks.ago
      assert_equal 20, @developer.score_for(:profile_updated_at)
    end

    test "medium boost for profile updated 1-3 months ago" do
      @developer.profile_updated_at = 2.months.ago
      assert_equal 10, @developer.score_for(:profile_updated_at)
    end

    test "no boost for profile updated 3-6 months ago" do
      @developer.profile_updated_at = 5.months.ago
      assert_equal 0, @developer.score_for(:profile_updated_at)
    end

    test "medium demotion for profile updated more than 6 months ago" do
      @developer.profile_updated_at = 7.months.ago
      assert_equal -10, @developer.score_for(:profile_updated_at)
    end

    test "extra large boost for profiles added in the last week" do
      @developer.created_at = 6.days.ago
      assert_equal 30, @developer.score_for(:recently_added?)
    end

    test "medium boost for bios with more than 500 characters" do
      @developer.bio = "X" * 501
      assert_equal 10, @developer.score_for(:bio)
    end

    test "large demotion for bios with fewer than 50 characters" do
      @developer.bio = "X" * 49
      assert_equal -20, @developer.score_for(:bio)
    end
  end
end