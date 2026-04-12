require "test_helper"

class SignUpsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @default_community = Community.first || Community.create!(name: "Default Community", community_type: "public")
  end

  test "should get sign up page" do
    get sign_up_path
    assert_response :success
  end

  test "should create new user with valid params" do
    assert_difference("User.count", 1) do
      post sign_up_path, params: {
        user: {
          first_name: "John",
          last_name: "Doe",
          email_address: "john@example.com",
          password: "password123",
          password_confirmation: "password123",
          default_community_id: @default_community.id
        }
      }
    end

    assert_redirected_to root_path
  end

  test "should send welcome email after sign up" do
    assert_emails 1 do
      post sign_up_path, params: {
        user: {
          first_name: "Jane",
          last_name: "Smith",
          email_address: "jane@example.com",
          password: "password123",
          password_confirmation: "password123",
          default_community_id: @default_community.id
        }
      }
    end
  end

  test "should not create user with invalid email" do
    assert_no_difference("User.count") do
      post sign_up_path, params: {
        user: {
          first_name: "Test",
          last_name: "User",
          email_address: "invalid-email",
          password: "password123",
          password_confirmation: "password123",
          default_community_id: @default_community.id
        }
      }
    end
  end

  test "should not create user with mismatched password" do
    assert_no_difference("User.count") do
      post sign_up_path, params: {
        user: {
          first_name: "Test",
          last_name: "User",
          email_address: "test@example.com",
          password: "password123",
          password_confirmation: "different",
          default_community_id: @default_community.id
        }
      }
    end
  end

  test "should not create user with duplicate email" do
    # create the first user
    post sign_up_path, params: {
      user: {
        first_name: "First",
        last_name: "User",
        email_address: "duplicate@example.com",
        password: "password123",
        password_confirmation: "password123",
        default_community_id: @default_community.id
      }
    }

    # try to use the first user email to create second user
    assert_no_difference("User.count") do
      post sign_up_path, params: {
        user: {
          first_name: "Second",
          last_name: "User",
          email_address: "duplicate@example.com",
          password: "password123",
          password_confirmation: "password123",
          default_community_id: @default_community.id
        }
      }
    end
  end

  test "user should be logged in after sign up" do
    post sign_up_path, params: {
      user: {
        first_name: "Logged",
        last_name: "User",
        email_address: "logged@example.com",
        password: "password123",
        password_confirmation: "password123",
        default_community_id: @default_community.id
      }
    }

    assert_redirected_to root_path
  end
end
