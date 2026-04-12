# db/seeds/04_items.rb
require "open-uri"

items = [
  { title: "Calculus Textbook", price: 200, condition: "good", category_name: "Books", email: "student1@link.cuhk.edu.hk", community_name: "Chung Chi College" },
  { title: "iPhone 13", price: 3500, condition: "like_new", category_name: "Electronics", email: "student2@link.cuhk.edu.hk", community_name: "New Asia College" },
  { title: "Dorm Chair", price: 150, condition: "fair", category_name: "Furniture", email: "student3@link.cuhk.edu.hk", community_name: "United College" },
  { title: "Hoodie", price: 100, condition: "brand_new", category_name: "Clothing", email: "student1@link.cuhk.edu.hk", community_name: "Chung Chi College" },
  { title: "Kettle", price: 80, condition: "poor", category_name: "Kitchenware", email: "student2@link.cuhk.edu.hk", community_name: "Shaw College" }
]

puts "Seeding items..."
items.each do |item_attr|
  category = Category.find_by(name: item_attr[:category_name])
  seller = User.find_by(email_address: item_attr[:email])
  community = Community.find_by(name: item_attr[:community_name])

  item = Item.find_or_create_by!(title: item_attr[:title], seller: seller) do |i|
    i.price = item_attr[:price]
    i.condition = item_attr[:condition]
    i.status = "available"
    i.category = category
    i.community = community
  end

  unless item.photo.attached?
    filename = "#{item_attr[:title].parameterize}.png"
    cache_path = Rails.root.join("db", "seeds", "images", filename)

    unless cache_path.exist?
      cache_path.dirname.mkpath
      label = item_attr[:title].gsub(" ", "+")
      url = "https://placehold.co/400x300.png?text=#{label}"
      IO.copy_stream(URI.open(url), cache_path)
      puts "  Downloaded #{filename}"
    end

    item.photo.attach(
      io: File.open(cache_path),
      filename: filename,
      content_type: "image/png"
    )
    puts "  Attached photo for #{item_attr[:title]}"
  end
end
