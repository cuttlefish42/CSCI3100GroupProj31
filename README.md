# README
[Proposal](https://docs.google.com/document/d/1oOtpxZJiM1y9OBDHpL1dVIxfQdqSu73XgRC2idw4MRA)
[Deploymnent Url](http://35.175.182.169/)


# Ruby version
Uses 3.3.8. Recommended to install it via [rvm](https://rvm.io)

# Configuration
Make sure rails secret is put at `config/master.key`. Obtain the rails secret in repo's `Settings > Secrets and variables > Actions > RAILS_MASTER_KEY`

# Development
Run `bin/setup` to setup dependencies and database.

If you want to reset your local db, use `bin/rails db:reset`


# Running test suite
## Unit tests
To run unit test, use `bin/rails test`.

## System test
To run sysmtem test, use `bin/rails test:system`. (None for now)

# Services
None for now

# Run locally
Since we also uses tailwindcss + daisyUI for the frontend, please use
```
bin/dev
```
to start dev server.

# Mail
Preview mails at http://localhost:3000/letter_opener/

# Deployment
The deployment is automated via github actions and kamal. It would be automatically pushed to production server after it passes all the tests.
