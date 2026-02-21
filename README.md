# README
[Proposal](https://docs.google.com/document/d/1oOtpxZJiM1y9OBDHpL1dVIxfQdqSu73XgRC2idw4MRA)
[Deploymnent Url](http://35.175.182.169/)

# Ruby version
Uses 3.3.8. Recommended to install it via [rvm](https://rvm.io)

# System dependencies
Run `bundle install` to install all necessary gems.

# Configuration
Make sure rails secret is put at `config/master.key`. Obtain the rails secret in repo's `Settings > Secrets and variables > Actions > RAILS_MASTER_KEY`

# Database creation
Create database: `bin/rails db:create`
Initialize schema: `bin/rails db:migrate`

# Database initialization
Populate dummy data: `bin/rails db:seed` (None for now)

# Running test suite
## Unit tests
To run unit test, use `bin/rails test`.

## System test
To run sysmtem test, use `bin/rails test:system`. (None for now)

# Services
None for now

# Run locally
Use `bin/rails server`

# Deployment
The deployment is automated via github actions and kamal. It would be automatically pushed to production server after it passes all the tests.
