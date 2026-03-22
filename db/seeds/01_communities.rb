# db/seeds/01_communities.rb

communities = [
  { name: "Chung Chi College", community_type: "College" },
  { name: "New Asia College", community_type: "College" },
  { name: "United College", community_type: "College" },
  { name: "Shaw College", community_type: "College" },
  { name: "Morningside College", community_type: "College" },
  { name: "S.H. Ho College", community_type: "College" },
  { name: "CW Chu College", community_type: "College" },
  { name: "Wu Yee Sun College", community_type: "College" },
  { name: "Lee Woo Sing College", community_type: "College" }
]

puts "Seeding communities..."
communities.each do |community_attr|
  Community.find_or_create_by!(name: community_attr[:name]) do |c|
    c.community_type = community_attr[:community_type]
  end
end

