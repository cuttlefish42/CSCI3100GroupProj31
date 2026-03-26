# db/seeds/03_users.rb

users = [
  { email: "admin@link.cuhk.edu.hk", username: "admin", community_name: "Chung Chi College" },

  { email: "student1@link.cuhk.edu.hk", username: "student1", community_name: "New Asia College" },
  { email: "student2@link.cuhk.edu.hk", username: "student2", community_name: "United College" },
  { email: "student3@link.cuhk.edu.hk", username: "student3", community_name: "Shaw College" }
]

puts "Seeding users..."
users.each do |user_attr|
  community = Community.find_by(name: user_attr[:community_name])

  User.find_or_create_by!(email_address: user_attr[:email]) do |u|
    u.username = user_attr[:username]
    u.password = "password123"
    u.password_confirmation = "password123"
    u.default_community_id = community&.id
  end
end
