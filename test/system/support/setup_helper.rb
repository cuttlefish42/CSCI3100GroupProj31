module SetupHelper
  def create_sample_users(count:, karma_sequence: nil)
    count.times do |i|
      karma_value = karma_sequence ? karma_sequence.call(i) : i

      User.create!(
        email_address: "sample_user_#{i}@link.cuhk.edu.hk",
        first_name: "Sample",
        last_name: "User#{i}",
        password: "password123",
        password_confirmation: "password123",
        karma: karma_value
      )
    end
  end

  def create_sample_items(count:)
    seller = User.find_or_create_by!(email_address: "test_seller@link.cuhk.edu.hk") do |u|
      u.first_name = "Test"
      u.last_name = "Seller"
      u.password = "password123"
      u.password_confirmation = "password123"
      u.karma = 0
    end

    create_sample_communities()
    create_sample_categories()

    category = Category.find_by!(name: "Books")
    community = Community.find_by!(name: "Chung Chi College")

    count.times do |i|
      n = i + 1
      Item.find_or_create_by!(title: "Sample Item #{n}", seller: seller) do |item|
        item.price = 100
        item.condition = :good
        item.status = :available
        item.category = category
        item.community = community
      end
    end
  end

  def create_sample_communities()
    community = Community.find_or_create_by!(name: "Chung Chi College") do |c|
      c.community_type = "College"
    end
  end

  def create_sample_categories()
    category = Category.find_or_create_by!(name: "Books")
  end

  def login_user_as(email:, password:)
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Sign in"
  end
end
