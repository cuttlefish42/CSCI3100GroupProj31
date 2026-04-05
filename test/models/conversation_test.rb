require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  test "between finds conversation regardless of order" do
    convo = conversations(:one) # sender: one, receiver: two
    assert_equal convo, Conversation.between(users(:one), users(:two))
    assert_equal convo, Conversation.between(users(:two), users(:one))
  end

  test "between returns nil when no conversation exists" do
    assert_nil Conversation.between(users(:one), users(:three))
  end

  test "find_or_create_between returns existing conversation" do
    convo = conversations(:one)
    assert_no_changes -> { Conversation.count } do
      found = Conversation.find_or_create_between(users(:one), users(:two))
      assert_equal convo, found
    end
  end

  test "find_or_create_between creates new when none exists" do
    assert_changes -> { Conversation.count }, +1 do
      convo = Conversation.find_or_create_between(users(:one), users(:three))
      assert_equal users(:one), convo.sender
      assert_equal users(:three), convo.receiver
    end
  end

  test "participates? returns true for sender" do
    convo = conversations(:one)
    assert convo.participates?(users(:one))
  end

  test "participates? returns true for receiver" do
    convo = conversations(:one)
    assert convo.participates?(users(:two))
  end

  test "participates? returns false for non-participant" do
    convo = conversations(:one)
    assert_not convo.participates?(users(:three))
  end

  test "involves scope returns conversations for a user" do
    convos = Conversation.involves(users(:two))
    assert_includes convos, conversations(:one)  # receiver
    assert_includes convos, conversations(:two)   # sender
  end

  test "recent scope orders by updated_at desc" do
    old = conversations(:one)
    recent = conversations(:two)
    recent.update!(updated_at: 1.minute.from_now)

    results = Conversation.recent
    assert_operator results.index(recent), :<, results.index(old)
  end
end
