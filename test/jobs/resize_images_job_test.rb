require "test_helper"

class ResizeImagesJobTest < ActiveJob::TestCase
  test "does nothing for non-existent item" do
    assert_nothing_raised do
      ResizeImagesJob.perform_now(999_999)
    end
  end

  test "does nothing for item without photo" do
    item = items(:one)
    assert_nothing_raised do
      ResizeImagesJob.perform_now(item.id)
    end
  end
end
