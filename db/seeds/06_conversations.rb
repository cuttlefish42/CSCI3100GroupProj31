puts "Creating Conversations and Messages..."

users = User.limit(3).to_a

if users.size >= 2
  user1, user2, user3 = users

  # ---------------------------------------------------------------------------
  # Conversation 1: General inquiry referencing an Item
  # ---------------------------------------------------------------------------
  conv1 = Conversation.find_or_create_between(user1, user2)
  item = Item.first

  if conv1.messages.empty?
    conv1.messages.create!(
      sender: user1,
      content: "Hi, I'm interested in your item. Is it still available?",
      item: item
    )

    # Simulate a slight delay so they sort chronologically
    sleep(1)

    conv1.messages.create!(
      sender: user2,
      content: "Hello! Yes, it's still available. Are you willing to pick it up on campus?"
    )

    sleep(1)

    conv1.messages.create!(
      sender: user1,
      content: "Sure, I can meet at the library."
    )
  end

  # ---------------------------------------------------------------------------
  # Conversation 2: Chat referencing an Offer
  # ---------------------------------------------------------------------------
  if user3
    conv2 = Conversation.find_or_create_between(user2, user3)
    offer = Offer.first

    if conv2.messages.empty?
      if offer
        conv2.messages.create!(
          sender: user3,
          content: "I just made an offer for $#{offer.price_offered}.",
          offer: offer
        )

        sleep(1)

        conv2.messages.create!(
          sender: user2,
          content: "Thanks for the offer! I will review it shortly."
        )
      else
        conv2.messages.create!(
          sender: user3,
          content: "Hey, are you open to negotiating the price?"
        )

        sleep(1)

        conv2.messages.create!(
          sender: user2,
          content: "I'm firm on the price right now, sorry!"
        )
      end
    end
  end

  puts "✅ Conversations and Messages seeded."
else
  puts "⚠️ Not enough users found to seed conversations. Please run earlier seeds first."
end
