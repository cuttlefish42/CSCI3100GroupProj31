require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get items_url
    assert_response :success
  end

  test "should get show" do
    get item_url(items(:one))
    assert_response :success
  end

  test "new requires authentication" do
    get new_item_path
    assert_redirected_to new_session_path
  end

  test "create requires authentication" do
    assert_no_changes -> { Item.count } do
      post items_path, params: { item: { title: "Widget", description: "A widget", price: 10, condition: "good", status: "available", category_id: categories(:one).id, community_id: communities(:one).id } }
      assert_redirected_to new_session_path
    end
  end

  test "authenticated user can create" do
    user = users(:one)
    sign_in_as(user)

    assert_changes -> { Item.count }, +1 do
      post items_path, params: { item: { title: "Widget", description: "A widget", price: 10, condition: "good", status: "available", category_id: categories(:one).id, community_id: communities(:one).id } }
    end

    item = Item.order(:created_at).last
    assert_equal user, item.seller
    assert_redirected_to item_url(item)
  end

  test "authenticated user can update" do
    user = users(:one)
    sign_in_as(user)

    patch item_path(items(:one)), params: { item: { status: "reserved" } }

    assert_redirected_to item_url(items(:one))
    assert_equal "reserved", items(:one).reload.status
  end

  test "cannot update another user's item" do
    user = users(:one)
    sign_in_as(user)

    assert_no_changes -> { items(:two).reload.status } do
      patch item_path(items(:two)), params: { item: { status: "reserved" } }
      assert_redirected_to items_url
    end
  end

  test "authenticated user can destroy" do
    user = users(:one)
    sign_in_as(user)

    assert_changes -> { Item.count }, -1 do
      delete item_path(items(:one))
    end

    assert_redirected_to items_url
  end

  test "show increments views_count" do
    item = items(:one)
    assert_changes -> { item.reload.views_count }, from: 0, to: 1 do
      get item_url(item)
    end
    assert_response :success
  end

  test "toggle_like requires authentication" do
    assert_no_changes -> { Like.count } do
      post toggle_like_item_path(items(:one))
      assert_redirected_to new_session_path
    end
  end

  test "toggle_like creates a like" do
    sign_in_as(users(:one))

    assert_changes -> { Like.count }, from: 1, to: 2 do
      post toggle_like_item_path(items(:one))
    end
  end

  test "toggle_like removes an existing like" do
    sign_in_as(users(:one))
    Like.create!(user: users(:one), item: items(:one))

    assert_changes -> { Like.count }, from: 2, to: 1 do
      post toggle_like_item_path(items(:one))
    end
  end

  test "cannot destroy another user's item" do
    user = users(:one)
    sign_in_as(user)

    assert_no_changes -> { Item.count } do
      delete item_path(items(:two))
      assert_redirected_to items_url
    end
  end
end
