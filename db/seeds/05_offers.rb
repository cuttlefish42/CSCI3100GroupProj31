# db/seeds/05_offers.rb

puts "Seeding offers..."

student1 = User.find_by(email_address: "student1@link.cuhk.edu.hk")
student2 = User.find_by(email_address: "student2@link.cuhk.edu.hk")
student3 = User.find_by(email_address: "student3@link.cuhk.edu.hk")

# student2 offers on student1's Calculus Textbook
calculus = Item.find_by(title: "Calculus Textbook")
if calculus
  Offer.find_or_create_by!(buyer: student2, item: calculus) do |o|
    o.price_offered = 150
  end
  Offer.find_or_create_by!(buyer: student3, item: calculus) do |o|
    o.price_offered = 180
  end
end

# student1 offers on student2's iPhone 13
iphone = Item.find_by(title: "iPhone 13")
if iphone
  Offer.find_or_create_by!(buyer: student1, item: iphone) do |o|
    o.price_offered = 3000
  end
end
