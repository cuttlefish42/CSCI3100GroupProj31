# db/seeds/03_users.rb

users = [
  { email: "admin@link.cuhk.edu.hk", username: "admin", first_name: "Admin", last_name: "User", community_name: "Chung Chi College" },

  { email: "student1@link.cuhk.edu.hk", username: "student1", first_name: "Alice", last_name: "Chan", community_name: "New Asia College" },
  { email: "student2@link.cuhk.edu.hk", username: "student2", first_name: "Bob", last_name: "Wong", community_name: "United College" },
  { email: "student3@link.cuhk.edu.hk", username: "student3", first_name: "Charlie", last_name: "Lee", community_name: "Shaw College" }
]

puts "Seeding users..."
users.each do |user_attr|
  community = Community.find_by(name: user_attr[:community_name])

  k = 1
  User.find_or_create_by!(email_address: user_attr[:email]) do |u|
    u.first_name = user_attr[:first_name]
    u.last_name = user_attr[:last_name]
    u.password = "password123"
    u.password_confirmation = "password123"
    u.default_community_id = community&.id
    u.karma = k
    k = k + 1
  end
end
