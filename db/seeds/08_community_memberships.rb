# db/seeds/08_community_memberships.rb

puts "Seeding community memberships..."

admin_user = User.find_by(email_address: "admin@link.cuhk.edu.hk")

if admin_user
  Community.find_each do |community|
    CommunityMembership.find_or_create_by!(user: admin_user, community: community) do |m|
      m.role = :admin
    end
    puts "  #{admin_user.full_name} is admin of #{community.name}"
  end
end
