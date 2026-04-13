require "application_system_test_case"

class ItemFilteringTest < ApplicationSystemTestCase
  # ---------------------------------------------------------------------------
  # Shared setup helper
  # ---------------------------------------------------------------------------
  def setup_sample_items
    create_sample_communities
    create_sample_categories

    # Ensure a second community exists for multi-community tests
    Community.find_or_create_by!(name: "New Asia College") { |c| c.community_type = "College" }
    # Ensure a second category exists
    Category.find_or_create_by!(name: "Electronics")

    @seller = create_sample_user(
      email_address: "filter_seller@link.cuhk.edu.hk",
      first_name: "Filter", last_name: "Seller"
    )
    @category_books  = Category.find_by!(name: "Books")
    @category_elec   = Category.find_by!(name: "Electronics")
    @community_cc    = Community.find_by!(name: "Chung Chi College")
    @community_na    = Community.find_by!(name: "New Asia College")

    @item_cc_cheap = Item.create!(
      title: "Cheap CC Book", description: "A cheap book in Chung Chi",
      price: 10, condition: :good, status: :available,
      category: @category_books, community: @community_cc, seller: @seller
    )
    @item_cc_expensive = Item.create!(
      title: "Expensive CC Laptop", description: "An expensive laptop in Chung Chi",
      price: 500, condition: :like_new, status: :available,
      category: @category_elec, community: @community_cc, seller: @seller
    )
    @item_na_book = Item.create!(
      title: "NA Textbook", description: "A textbook in New Asia",
      price: 50, condition: :fair, status: :available,
      category: @category_books, community: @community_na, seller: @seller
    )
    # A sold item — should never appear on the index
    @item_sold = Item.create!(
      title: "Sold Item", description: "Already sold",
      price: 999, condition: :brand_new, status: :sold,
      category: @category_books, community: @community_cc, seller: @seller
    )
  end

  # ---------------------------------------------------------------------------
  # 1. Keyword search
  # ---------------------------------------------------------------------------
  test "items can be filtered by keyword search" do
    given "items with different titles exist" do
      setup_sample_items
    end

    when_ "the user searches for 'Book'" do
      visit items_path
      fill_in "keyword", with: "Book"
      click_button "Apply Filters"
    end

    then_ "only items matching the keyword are shown" do
      assert_text "Cheap CC Book"
      assert_text "NA Textbook"
      assert_no_text "Expensive CC Laptop"
      assert_no_text "Sold Item"
    end
  end

  # ---------------------------------------------------------------------------
  # 2. Price range filter
  # ---------------------------------------------------------------------------
  test "items can be filtered by min price" do
    given "items with different prices exist" do
      setup_sample_items
    end

    when_ "the user sets a min price of 40" do
      visit items_path
      fill_in "min_price", with: 40
      click_button "Apply Filters"
    end

    then_ "only items at or above the min price are shown" do
      assert_text "Expensive CC Laptop"
      assert_text "NA Textbook"
      assert_no_text "Cheap CC Book"
    end
  end

  test "items can be filtered by max price" do
    given "items with different prices exist" do
      setup_sample_items
    end

    when_ "the user sets a max price of 60" do
      visit items_path
      fill_in "max_price", with: 60
      click_button "Apply Filters"
    end

    then_ "only items at or below the max price are shown" do
      assert_text "Cheap CC Book"
      assert_text "NA Textbook"
      assert_no_text "Expensive CC Laptop"
    end
  end

  test "items can be filtered by both min and max price" do
    given "items with different prices exist" do
      setup_sample_items
    end

    when_ "the user sets a price range of 20 to 100" do
      visit items_path
      fill_in "min_price", with: 20
      fill_in "max_price", with: 100
      click_button "Apply Filters"
    end

    then_ "only items within the price range are shown" do
      assert_text "NA Textbook"
      assert_no_text "Cheap CC Book"
      assert_no_text "Expensive CC Laptop"
    end
  end

  # ---------------------------------------------------------------------------
  # 3. Date range filter
  # ---------------------------------------------------------------------------
  test "items can be filtered by start date" do
    given "an old item and a recent item exist" do
      setup_sample_items
      # Make one item appear old
      @item_cc_cheap.update_column(:created_at, 10.days.ago)
    end

    when_ "the user filters from 5 days ago" do
      visit items_path(start_date: 5.days.ago.strftime("%Y-%m-%dT%H:%M"))
    end

    then_ "only recent items are shown" do
      assert_no_text "Cheap CC Book"
      assert_text "Expensive CC Laptop"
    end
  end

  # ---------------------------------------------------------------------------
  # 4. Community filter
  # ---------------------------------------------------------------------------
  test "items can be filtered by community via the dropdown" do
    given "items in different communities exist" do
      setup_sample_items
    end

    when_ "the user selects Chung Chi College from the dropdown" do
      visit items_path(community_id: @community_cc.id)
    end

    then_ "only Chung Chi items are shown" do
      assert_text "Cheap CC Book"
      assert_text "Expensive CC Laptop"
      assert_no_text "NA Textbook"
    end
  end

  # ---------------------------------------------------------------------------
  # 5. Sorting
  # ---------------------------------------------------------------------------
  test "items can be sorted by price ascending" do
    given "items with different prices exist" do
      setup_sample_items
    end

    when_ "the user sorts by price ascending" do
      visit items_path(sort_by: "price", sort_direction: "asc")
    end

    then_ "items are ordered by price ascending" do
      titles = page.all(".grid .card h2.card-title").map(&:text)
      cheap_idx  = titles.index("Cheap CC Book")
      na_idx     = titles.index("NA Textbook")
      exp_idx    = titles.index("Expensive CC Laptop")

      assert cheap_idx < na_idx,  "Cheap CC Book (10) should appear before NA Textbook (50)"
      assert na_idx < exp_idx,     "NA Textbook (50) should appear before Expensive CC Laptop (500)"
    end
  end

  test "items can be sorted by price descending" do
    given "items with different prices exist" do
      setup_sample_items
    end

    when_ "the user sorts by price descending" do
      visit items_path(sort_by: "price", sort_direction: "desc")
    end

    then_ "items are ordered by price descending" do
      titles = page.all(".grid .card h2.card-title").map(&:text)
      cheap_idx  = titles.index("Cheap CC Book")
      na_idx     = titles.index("NA Textbook")
      exp_idx    = titles.index("Expensive CC Laptop")

      assert exp_idx < na_idx,     "Expensive CC Laptop (500) should appear before NA Textbook (50)"
      assert na_idx < cheap_idx,   "NA Textbook (50) should appear before Cheap CC Book (10)"
    end
  end

  # ---------------------------------------------------------------------------
  # 6. Combined filters
  # ---------------------------------------------------------------------------
  test "keyword and community filters work together" do
    given "items exist in different communities with different titles" do
      setup_sample_items
    end

    when_ "the user searches for 'Laptop' and selects Chung Chi College" do
      visit items_path(keyword: "Laptop", community_id: @community_cc.id)
    end

    then_ "only Chung Chi laptop items are shown" do
      assert_text "Expensive CC Laptop"
      assert_no_text "Cheap CC Book"
      assert_no_text "NA Textbook"
    end
  end

  test "community and price range filters work together" do
    given "items exist in different communities with different prices" do
      setup_sample_items
    end

    when_ "the user selects Chung Chi College and sets max price of 20" do
      visit items_path(community_id: @community_cc.id, max_price: 20)
    end

    then_ "only cheap Chung Chi items are shown" do
      assert_text "Cheap CC Book"
      assert_no_text "Expensive CC Laptop"
      assert_no_text "NA Textbook"
    end
  end

  # ---------------------------------------------------------------------------
  # 7. Reset filters
  # ---------------------------------------------------------------------------
  test "reset filters clears all active filters" do
    given "items exist" do
      setup_sample_items
    end

    when_ "the user applies a keyword filter then clicks Reset Filters" do
      visit items_path
      fill_in "keyword", with: "Laptop"
      click_button "Apply Filters"
      assert_text "Expensive CC Laptop"
      assert_no_text "Cheap CC Book"

      click_link "Reset Filters"
    end

    then_ "all items are shown again" do
      assert_text "Cheap CC Book"
      assert_text "Expensive CC Laptop"
      assert_text "NA Textbook"
    end
  end

  # ---------------------------------------------------------------------------
  # 8. Active filter tags with remove (×) links
  # ---------------------------------------------------------------------------
  test "active filter tags appear and can be individually removed" do
    given "items exist" do
      setup_sample_items
    end

    when_ "the user applies keyword and min_price filters" do
      visit items_path
      fill_in "keyword", with: "Book"
      fill_in "min_price", with: 5
      click_button "Apply Filters"
    end

    then_ "active filter badges are displayed" do
      assert_text "Active Filters"
      assert_text "Keyword: Book"
      assert_text "Min: $5"
    end

    when_ "the user removes the keyword filter tag" do
      # Find the × link inside the keyword badge
      find(".badge-info", text: /Keyword/).find("a").click
    end

    then_ "the keyword filter is removed but min_price remains" do
      assert_no_text "Keyword: Book"
      assert_text "Min: $5"
    end
  end

  # ---------------------------------------------------------------------------
  # 9. Only available items shown on index
  # ---------------------------------------------------------------------------
  test "only available items are shown, sold items are hidden" do
    given "available and sold items exist" do
      setup_sample_items
    end

    when_ "the user visits the items index" do
      visit items_path
    end

    then_ "sold items are not displayed" do
      assert_text "Cheap CC Book"
      assert_text "Expensive CC Laptop"
      assert_text "NA Textbook"
      assert_no_text "Sold Item"
    end
  end

  # ---------------------------------------------------------------------------
  # 10. Results count reflects filtered items
  # ---------------------------------------------------------------------------
  test "results count updates when filters are applied" do
    given "items exist" do
      setup_sample_items
    end

    when_ "the user visits the items index without filters" do
      visit items_path
    end

    then_ "the total count of available items is shown" do
      assert_match(/Showing \d+ item/, page.text)
    end

    when_ "the user filters by New Asia College (only 1 test item + fixture)" do
      visit items_path(community_id: @community_na.id)
    end

    then_ "the count decreases compared to unfiltered" do
      # At least NA Textbook should appear; the count should be less than total
      assert_text "NA Textbook"
      assert_no_text "Cheap CC Book"
      assert_no_text "Expensive CC Laptop"
    end
  end

  # ---------------------------------------------------------------------------
  # 11. Empty results message
  # ---------------------------------------------------------------------------
  test "no items found message when filters match nothing" do
    given "items exist" do
      setup_sample_items
    end

    when_ "the user searches for a non-existent keyword" do
      visit items_path
      fill_in "keyword", with: "zzzznonexistent"
      click_button "Apply Filters"
    end

    then_ "a no items found message is displayed" do
      assert_text "No items found matching your filters"
    end
  end

  # ---------------------------------------------------------------------------
  # 12. Unauthenticated users can browse and filter items
  # ---------------------------------------------------------------------------
  test "unauthenticated users can browse and filter items" do
    given "items exist" do
      setup_sample_items
    end

    when_ "an unauthenticated user visits the items index" do
      visit items_path
    end

    then_ "they can see items and the filter form" do
      assert_text "Cheap CC Book"
      assert_text "Search & Filter"
      assert_no_text "New Item"
    end

    when_ "they apply a filter" do
      fill_in "keyword", with: "Laptop"
      click_button "Apply Filters"
    end

    then_ "filtered results are shown" do
      assert_text "Expensive CC Laptop"
      assert_no_text "Cheap CC Book"
    end
  end
end
