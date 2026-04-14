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
To run system test, use `bin/rails test:system`.

# Documentation
- [Offer & Item State Management](docs/offer_fsm.pdf) — Diagram showing offer/item status transitions and routes

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

# Features

| #  | Feature                                          | Primary Dev     | Secondary Dev                        | Notes                                                                 |
| -- | ------------------------------------------------ | --------------- | ------------------------------------ | --------------------------------------------------------------------- |
| 1  | Project Init & Kamal Deployment                  | cuttlefish      | —                                    | Rails 8 scaffold, CI/CD, GitHub Actions                               |
| 2  | Authentication (Login/Register/Forgot Password)  | RC063           | cuttlefish                           | bcrypt (has_secure_password), Rails session cookies                    |
| 3  | User Registration / Sign-up Flow                 | LAM KEI HUNG    | cuttlefish                           | bcrypt, Action Mailer (welcome email)                                 |
| 4  | Core Models & Item CRUD                          | cuttlefish      | —                                    | ActiveRecord, Active Storage                                          |
| 5  | UI Framework                | cuttlefish      | —                                    | Tailwind CSS, daisyUI, dark mode toggle                               |
| 6  | Offer / Negotiation System                       | RC063           | cuttlefish                           | ActiveRecord enum (state machine), Turbo Streams                       |
| 7  | Counter-Offer Flow                               | RC063           | cuttlefish                           | ActiveRecord enum (state machine), Turbo Streams                       |
| 8  | Item Status Management                           | RC063           | —                                    | ActiveRecord enum (available/reserved/sold)                            |
| 9  | Image Upload                                     | RC063           | cuttlefish                           | Active Storage, image_processing (libvips)                             |
| *10 | Background Jobs (Sidekiq / Image Resizing)       | cuttlefish      | BrianLPL27                           | Sidekiq, Redis, image_processing (libvips)                             |
| *11 | Stale Items Cleanup Job                          | BrianLPL27      | cuttlefish                           | Sidekiq, Whenever (cron scheduler)                                     |
| *12 | Daily Digest Email                               | BrianLPL27      | —                                    | Action Mailer, Sidekiq                                                 |
| *13 | Leaflet Map (OpenStreetMap)                      | RC063           | —                                    | Leaflet.js, OpenStreetMap tiles, Stimulus                              |
| *14 | Chart.js Analytics                               | massivemoron345 | cuttlefish                           | Chart.js, ActiveRecord (ItemSnapshot), Sidekiq (hourly snapshot job)   |
| 15 | Karma Leaderboard                                | massivemoron345 | —                                    | Chart.js, ActiveRecord (User karma columns)                            |
| 16 | Dashboard (DRY partials + Pending Transactions)  | massivemoron345 | —                                    | Turbo Streams, ActiveRecord                                            |
| 17 | Website Header / Navbar                          | massivemoron345 | —                                    | daisyUI navbar component, lucide-rails icons                           |
| *18 | Real-time Chat (ActionCable + Turbo Streams)     | cuttlefish      | —                                    | Action Cable (solid_cable), Turbo Streams (turbo-rails), Stimulus      |
| *19 | Email / Mailer System                            | LAM KEI HUNG    | cuttlefish                           | Action Mailer, Gmail SMTP, Letter Opener (dev)                         |
| 20 | Review System                                    | RC063           | cuttlefish                           | ActiveRecord callbacks, enum (seller_review/buyer_review)              |
| 21 | Community Hub (Reddit-style)                     | cuttlefish      | —                                    | Action Text (rich text listing rules), ActiveRecord                    |
| 22 | User Profile Page                                | cuttlefish      | BrianLPL27                           | daisyUI tabs component, ActiveRecord                                   |
| 23 | Items Sort & Filter                              | cuttlefish      | BrianLPL27, massivemoron345          | ActiveRecord scopes, Tailwind CSS (collapsible UI)                     |
| 24 | Like Button                        | cuttlefish      | —                                    | Turbo Frames (turbo-rails), ActiveRecord counter_cache                 |
| 25 | Item View Count                                  | cuttlefish      | —                                    | ActiveRecord (counter columns)                                         |
| 26 | Landing Page                                     | cuttlefish      | —                                    | daisyUI hero/card components, lucide-rails icons                       |
| 27 | Production Deploy (PostgreSQL + Solid Trifecta)  | cuttlefish      | —                                    | Pos, Kamal, Docker, Tailscale Funnel    |
| 28 | Test Coverage                                    | cuttlefish      | massivemoron345, LAM KEI HUNG        | SimpleCov, Capybara, Selenium WebDriver                                |

*: Advance features