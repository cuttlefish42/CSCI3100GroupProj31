# README
[Proposal](https://docs.google.com/document/d/1oOtpxZJiM1y9OBDHpL1dVIxfQdqSu73XgRC2idw4MRA)
[Deploymnent Url](http://server1.li-exponential.ts.net/)


# Ruby version
Uses 3.3.8. Recommended to install it via [rvm](https://rvm.io)

# Configuration
Make sure rails secret is put at `config/master.key`. Obtain the rails secret in repo's `Settings > Secrets and variables > Actions > RAILS_MASTER_KEY`

# Development
Run `bin/setup` to setup dependencies and database.

Image processing (item thumbnails) uses libvips, which has to be installed
on the host:

```
sudo apt install libvips42 libvips-tools    # Ubuntu / WSL
brew install vips                            # macOS
```

If you want to reset your local db, use `bin/rails db:reset`


# Running test suite
## Unit tests
To run unit test, use `bin/rails test`.

## System test
To run sysmtem test, use `bin/rails test:system`. (None for now)

# Services
The app uses **Sidekiq** for background jobs (image thumbnail generation,
mail digests). Sidekiq needs **Redis**. The easiest way to get Redis on a
dev machine is via Docker Compose:

```
docker compose up -d        # starts Redis on localhost:6379
docker compose down         # stops it
```

If you'd rather install Redis natively (`sudo apt install redis-server`),
that works too — Sidekiq just needs *something* listening on port 6379.

# Run locally
Since we also use tailwindcss + daisyUI for the frontend, please use
```
bin/dev
```
to start dev server. `bin/dev` boots Puma, the Tailwind watcher, and the
Sidekiq worker via `Procfile.dev`. Make sure Redis is running first.

# Mail
Preview mails at http://localhost:3000/letter_opener/

# Deployment
The deployment is automated via github actions and kamal. It would be automatically pushed to production server after it passes all the tests.

## Running `kamal deploy` locally
For one-off deploys from your machine, you need a few env variables that the
GitHub Actions pipeline normally provides. Copy `.env.example` to `.env` and
fill in:

- `RAILS_MASTER_KEY` — contents of `config/master.key`
- `EC2_INSTANCE_ADDRESS` — SSH host/IP of the production server
- `KAMAL_REGISTRY_PASSWORD` — GitHub PAT with `write:packages`
- `GITHUB_TOKEN` — GitHub PAT with `read:packages` (can be the same token)

`config/deploy.yml` auto-loads `.env` via dotenv, so just running
`bin/kamal deploy` afterwards picks them up. The first time you deploy,
boot the Redis accessory once: `bin/kamal accessory boot redis`.
