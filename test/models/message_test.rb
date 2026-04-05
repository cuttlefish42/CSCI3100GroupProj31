require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "valid message with content" do
    message = messages(:one)
    assert message.valid?
  end

  test "message belongs to conversation" do
    message = messages(:one)
    assert_equal conversations(:one), message.conversation
  end

  test "message belongs to sender" do
    message = messages(:one)
    assert_equal users(:one), message.sender
  end

  test "item attachment is optional" do
    message = Message.new(
      conversation: conversations(:one),
      sender: users(:one),
      content: "No attachment"
    )
    assert message.valid?
    assert_nil message.item
  end

  test "offer attachment is optional" do
    message = Message.new(
      conversation: conversations(:one),
      sender: users(:one),
      content: "No attachment"
    )
    assert message.valid?
    assert_nil message.offer
  end

  test "message can have item attachment" do
    message = Message.new(
      conversation: conversations(:one),
      sender: users(:one),
      content: "Check this out",
      item: items(:one)
    )
    assert message.valid?
  end

  test "touch updates conversation timestamp" do
    convo = conversations(:one)
    original_time = convo.updated_at

    travel 1.minute do
      Message.create!(
        conversation: convo,
        sender: users(:one),
        content: "New message"
      )
      assert_operator convo.reload.updated_at, :>, original_time
    end
  end
end
