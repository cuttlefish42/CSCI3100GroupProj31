module SessionTestHelper
  def sign_in_as(user)
    # Use the fixture session (already in DB, visible to all connections)
    # instead of creating a new record that may not be visible across connections in parallel tests
    session = Session.find_by(user_id: user.id) || user.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = session.id
      cookies["session_id"] = cookie_jar[:session_id]
    end
  end

  def sign_out
    cookies.delete("session_id")
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include SessionTestHelper
end
