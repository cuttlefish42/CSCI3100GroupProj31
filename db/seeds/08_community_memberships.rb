# db/seeds/08_community_memberships.rb

puts "Seeding community memberships..."

# Make the first user admin of the first community
first_user = User.first
first_community = Community.first

if first_user && first_community
  CommunityMembership.find_or_create_by!(user: first_user, community: first_community) do |m|
    m.role = :admin
  end
  puts "  #{first_user.full_name} is admin of #{first_community.name}"
end
