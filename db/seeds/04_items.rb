# db/seeds/04_items.rb
require "vips"

items = [
  # Books
  { title: "Calculus Textbook", description: "MATH1010 textbook, some highlighting", price: 200, condition: "good", category_name: "Books", email: "student1@link.cuhk.edu.hk", community_name: "Chung Chi College" },
  { title: "Linear Algebra Notes", description: "MATH2010 full set of printed notes", price: 50, condition: "good", category_name: "Books", email: "student2@link.cuhk.edu.hk", community_name: "New Asia College" },
  { title: "Intro to CS Textbook", description: "CSCI1510, barely used", price: 180, condition: "like_new", category_name: "Books", email: "student3@link.cuhk.edu.hk", community_name: "United College" },
  { title: "Organic Chemistry", description: "CHEM2110, some notes in margins", price: 120, condition: "fair", category_name: "Books", email: "student1@link.cuhk.edu.hk", community_name: "Shaw College" },

  # Electronics
  { title: "iPhone 13", description: "128GB, blue, with case", price: 3500, condition: "like_new", category_name: "Electronics", email: "student2@link.cuhk.edu.hk", community_name: "New Asia College" },
  { title: "Mechanical Keyboard", description: "Cherry MX Brown, white backlight", price: 350, condition: "good", category_name: "Electronics", email: "student3@link.cuhk.edu.hk", community_name: "Morningside College" },
  { title: "iPad Air 5th Gen", description: "64GB WiFi, with Apple Pencil", price: 2800, condition: "like_new", category_name: "Electronics", email: "student1@link.cuhk.edu.hk", community_name: "S.H. Ho College" },
  { title: "USB-C Hub", description: "7-in-1 hub, HDMI + USB3 + SD", price: 80, condition: "brand_new", category_name: "Electronics", email: "student2@link.cuhk.edu.hk", community_name: "CW Chu College" },

  # Furniture
  { title: "Dorm Chair", description: "Ergonomic chair, used for one year", price: 150, condition: "fair", category_name: "Furniture", email: "student3@link.cuhk.edu.hk", community_name: "United College" },
  { title: "Desk Lamp", description: "LED desk lamp with USB charging port", price: 60, condition: "good", category_name: "Furniture", email: "student1@link.cuhk.edu.hk", community_name: "Wu Yee Sun College" },
  { title: "Bookshelf", description: "Small 3-tier shelf, fits dorm room", price: 100, condition: "fair", category_name: "Furniture", email: "student2@link.cuhk.edu.hk", community_name: "Lee Woo Sing College" },

  # Clothing
  { title: "Hoodie", description: "CUHK hoodie, never worn", price: 100, condition: "brand_new", category_name: "Clothing", email: "student1@link.cuhk.edu.hk", community_name: "Chung Chi College" },
  { title: "Lab Coat", description: "White lab coat, size M, used one semester", price: 40, condition: "good", category_name: "Clothing", email: "student3@link.cuhk.edu.hk", community_name: "New Asia College" },
  { title: "Running Shoes", description: "Nike Pegasus 39, size 42, worn twice", price: 400, condition: "like_new", category_name: "Clothing", email: "student2@link.cuhk.edu.hk", community_name: "Shaw College" },

  # Kitchenware
  { title: "Kettle", description: "Electric kettle, works fine", price: 80, condition: "poor", category_name: "Kitchenware", email: "student2@link.cuhk.edu.hk", community_name: "Shaw College" },
  { title: "Rice Cooker", description: "3-cup mini rice cooker, perfect for dorm", price: 90, condition: "good", category_name: "Kitchenware", email: "student1@link.cuhk.edu.hk", community_name: "Morningside College" },
  { title: "Cutlery Set", description: "Stainless steel set for 2, with case", price: 30, condition: "brand_new", category_name: "Kitchenware", email: "student3@link.cuhk.edu.hk", community_name: "CW Chu College" },

  # Sports & Outdoors
  { title: "Badminton Racket", description: "Yonex Astrox 88D, restrung recently", price: 300, condition: "good", category_name: "Sports & Outdoors", email: "student2@link.cuhk.edu.hk", community_name: "United College" },
  { title: "Yoga Mat", description: "6mm thick, purple, barely used", price: 50, condition: "like_new", category_name: "Sports & Outdoors", email: "student1@link.cuhk.edu.hk", community_name: "S.H. Ho College" },
  { title: "Basketball", description: "Spalding official size, outdoor", price: 80, condition: "fair", category_name: "Sports & Outdoors", email: "student3@link.cuhk.edu.hk", community_name: "Wu Yee Sun College" },

  # Free Items
  { title: "Lecture Notes Bundle", description: "Assorted ARTS faculty notes, free to a good home", price: 0, condition: "fair", category_name: "Free Items", email: "student1@link.cuhk.edu.hk", community_name: "Lee Woo Sing College" },
  { title: "Moving Out Box", description: "Misc dorm items, take what you need", price: 0, condition: "poor", category_name: "Free Items", email: "student2@link.cuhk.edu.hk", community_name: "Chung Chi College" }
]

puts "Seeding items..."
items.each do |item_attr|
  category = Category.find_by(name: item_attr[:category_name])
  seller = User.find_by(email_address: item_attr[:email])
  community = Community.find_by(name: item_attr[:community_name])

  item = Item.find_or_create_by!(title: item_attr[:title], seller: seller) do |i|
    i.description = item_attr[:description]
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
      # Generate placeholder image locally with libvips
      text = Vips::Image.text(item_attr[:title], dpi: 150, font: "sans")
      bg = Vips::Image.black(400, 300).colourspace(:srgb) + [204, 204, 204]
      x = [(400 - text.width) / 2, 0].max
      y = [(300 - text.height) / 2, 0].max
      img = bg.composite(text.colourspace(:srgb).invert, :over, x: x, y: y)
      img.pngsave(cache_path.to_s)
      puts "  Generated #{filename}"
    end

    item.photo.attach(
      io: File.open(cache_path),
      filename: filename,
      content_type: "image/png"
    )
    puts "  Attached photo for #{item_attr[:title]}"
  end
end
