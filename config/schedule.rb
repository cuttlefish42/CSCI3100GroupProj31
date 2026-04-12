every 1.day, at: '2:00 am' do
  runner "RemoveStaleItemsJob.perform_later"
end