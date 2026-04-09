# BDD-style tests with Capybara (no Cucumber)

Use `test/system/` for behavior-style scenarios:

- One scenario file per user journey (e.g. `authentication_flow_test.rb`)
- Structure each test using `given`, `when_`, `then_` blocks
- Keep setup in `given`, user actions in `when_`, assertions in `then_`

## Where to work

- Main scenario files: `test/system/*_test.rb`
- Shared step helpers: `test/system/support/bdd_steps.rb`
- Base system test config/driver: `test/application_system_test_case.rb`

## Run tests

- Run all system tests: `bin/rails test:system`
- Run one file: `bin/rails test test/system/authentication_flow_test.rb`
