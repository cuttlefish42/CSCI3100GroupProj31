# db/seeds/02_categories.rb

categories = [
  'Electronics',
  'Books',
  'Furniture',
  'Clothing',
  'Kitchenware',
  'Sports & Outdoors',
  'Free Items'
]

puts "Seeding categories..."
categories.each do |category_name|
  Category.find_or_create_by!(name: category_name)
end
