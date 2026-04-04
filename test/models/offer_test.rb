require "test_helper"

class OfferTest < ActiveSupport::TestCase
  test "valid offer" do
    offer = offers(:one)
    assert offer.valid?
  end

  test "buyer cannot be the seller" do
    item = items(:one)
    offer = Offer.new(buyer: item.seller, item: item, price_offered: 5.00)
    assert_not offer.valid?
    assert_includes offer.errors[:buyer], "cannot be the seller"
  end

  test "default status is pending" do
    offer = Offer.new(buyer: users(:two), item: items(:one), price_offered: 5.00)
    assert_equal "pending", offer.status
  end

  test "accept! marks offer as accepted and item as reserved" do
    offer = offers(:one)
    offer.item.update!(status: :available)
    offer.accept!

    assert offer.reload.accepted?
    assert offer.item.reload.reserved?
  end

  test "accept! rejects other pending offers on the same item" do
    item = items(:one)
    item.update!(status: :available)
    item.offers.destroy_all

    offer_a = Offer.create!(buyer: users(:two), item: item, price_offered: 10.00)
    offer_b = Offer.create!(buyer: users(:three), item: item, price_offered: 15.00)

    offer_a.accept!

    assert offer_a.reload.accepted?
    assert offer_b.reload.rejected?
  end

  test "price_offered must be greater than zero" do
    offer = Offer.new(buyer: users(:two), item: items(:one), price_offered: 0)
    assert_not offer.valid?
    assert_includes offer.errors[:price_offered], "must be greater than 0"
  end

  test "negative price_offered is invalid" do
    offer = Offer.new(buyer: users(:two), item: items(:one), price_offered: -5)
    assert_not offer.valid?
    assert_includes offer.errors[:price_offered], "must be greater than 0"
  end

  test "duplicate pending offer from same buyer is invalid" do
    existing = offers(:one)
    existing.update!(status: :pending)

    duplicate = Offer.new(buyer: existing.buyer, item: existing.item, price_offered: 20.00)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:base], "You already have an active offer on this item. Please edit your existing offer instead."
  end

  test "can create offer if previous offer was rejected" do
    existing = offers(:one)
    existing.update!(status: :rejected)

    new_offer = Offer.new(buyer: existing.buyer, item: existing.item, price_offered: 20.00)
    assert new_offer.valid?
  end

  test "counter! sets status to countered with counter_price" do
    offer = offers(:one)
    offer.counter!(75.00)

    assert offer.reload.countered?
    assert_equal 75.00, offer.counter_price.to_f
  end

  test "counter_price must be positive if present" do
    offer = offers(:one)
    offer.counter_price = -10
    assert_not offer.valid?
    assert_includes offer.errors[:counter_price], "must be greater than 0"
  end

  test "offer can have a message" do
    offer = offers(:one)
    offer.update!(message: "Is this still available?")
    assert_equal "Is this still available?", offer.reload.message
  end

  test "accept_counter! updates price and marks accepted and reserved" do
    offer = offers(:one)
    offer.update!(status: :countered, counter_price: 50.00)
    offer.item.update!(status: :available)

    offer.accept_counter!

    assert offer.reload.accepted?
    assert_equal 50.00, offer.price_offered.to_f
    assert offer.item.reload.reserved?
  end

  test "accept_counter! rejects other pending offers" do
    item = items(:one)
    item.update!(status: :available)
    item.offers.destroy_all

    offer_a = Offer.create!(buyer: users(:two), item: item, price_offered: 10.00)
    offer_b = Offer.create!(buyer: users(:three), item: item, price_offered: 15.00)

    offer_a.update!(status: :countered, counter_price: 12.00)
    offer_a.accept_counter!

    assert offer_a.reload.accepted?
    assert offer_b.reload.rejected?
  end

  test "cannot create offer on reserved item" do
    item = items(:one)
    item.update!(status: :reserved)

    offer = Offer.new(buyer: users(:three), item: item, price_offered: 5.00)
    assert_not offer.valid?
    assert_includes offer.errors[:base], "This item is no longer available for offers."
  end

  test "cannot create offer on sold item" do
    item = items(:one)
    item.update!(status: :sold)

    offer = Offer.new(buyer: users(:three), item: item, price_offered: 5.00)
    assert_not offer.valid?
    assert_includes offer.errors[:base], "This item is no longer available for offers."
  end
end
