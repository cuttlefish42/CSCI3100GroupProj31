module UserTestHelper
  def create_sample_user(attributes = {})
    default_attributes = {
      email_address: "sample_user_1@link.cuhk.edu.hk",
      first_name: "test_first_name",
      last_name: "test_last_name",
      password: "password123",
      password_confirmation: "password123"
    }
    User.create!(default_attributes.merge(attributes))
  end
end
