module BddSteps
  def given(description = nil)
    Rails.logger.debug("GIVEN #{description}") if description
    yield
  end

  def when_(description = nil)
    Rails.logger.debug("WHEN #{description}") if description
    yield
  end

  def then_(description = nil)
    Rails.logger.debug("THEN #{description}") if description
    yield
  end

  def last_email
    ActionMailer::Base.deliveries.last
  end

  def clear_emails
    ActionMailer::Base.deliveries.clear
  end
  
end
