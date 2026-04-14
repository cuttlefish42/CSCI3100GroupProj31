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
| 2  | Authentication (Login/Register/Forgot Password)  | RC063           | cuttlefish                           | cuttlefish fixed CI/linting issues on merge                           |
| 3  | User Registration / Sign-up Flow                 | LAM KEI HUNG    | cuttlefish                           | PR #49; issue #46                                                     |
| 4  | Core Models & Item CRUD                          | cuttlefish      | —                                    | PR #15; models, relationships, seeds, controllers                     |
| 5  | UI Framework (Tailwind + daisyUI)                | cuttlefish      | —                                    | Theme config, dark mode                                               |
| 6  | Offer / Negotiation System                       | RC063           | cuttlefish                           | PRs #28, #31; cuttlefish refactored into dedicated controllers (#30)  |
| 7  | Counter-Offer Flow                               | RC063           | cuttlefish                           | RC063 built UI; cuttlefish added accept/reject controllers            |
| 8  | Item Status Management                           | RC063           | —                                    | PR #25; available/reserved/sold enum                                  |
| 9  | Image Upload                                     | RC063           | cuttlefish                           | Photo upload for sellers; cuttlefish cleaned up on merge              |
| 10 | Background Jobs (Sidekiq / Image Resizing)       | cuttlefish      | BrianLPL27                           | BrianLPL27 added Sidekiq gem (PR #55); cuttlefish wrote ResizeImagesJob |
| 11 | Stale Items Cleanup Job                          | BrianLPL27      | cuttlefish                           | RemoveStaleItemsJob with whenever gem; cherry-picked by cuttlefish    |
| 12 | Daily Digest Email                               | BrianLPL27      | —                                    | Created a separate Listings model; had to be dropped (PR #68)         |
| 13 | Leaflet Map (OpenStreetMap)                      | RC063           | —                                    | PR #37; meetup location picker on item create/show                    |
| 14 | Chart.js Analytics                               | massivemoron345 | cuttlefish                           | PR #32 frontend; cuttlefish added item snapshot backend (PR #58)      |
| 15 | Karma Leaderboard                                | massivemoron345 | —                                    | PRs #33, #44; leaderboard page with sorting + chart                   |
| 16 | Dashboard (DRY partials + Pending Transactions)  | massivemoron345 | —                                    | PR #40; refactored into partials, buyer+seller pending view           |
| 17 | Website Header / Navbar                          | massivemoron345 | —                                    | PR #23                                                                |
| 18 | Real-time Chat (ActionCable + Turbo Streams)     | cuttlefish      | —                                    | PR #35; conversations, messages, per-user broadcast, dark mode fix    |
| 19 | Email / Mailer System                            | LAM KEI HUNG    | cuttlefish                           | PR #43; cuttlefish configured Gmail SMTP for production               |
| 20 | Review System                                    | RC063           | cuttlefish                           | PR #50; cuttlefish refactored to mutual review (both parties)         |
| 21 | Community Hub (Reddit-style)                     | cuttlefish      | —                                    | PR #75; memberships, sidebar, admin moderation, My Feed, ActionText   |
| 22 | User Profile Page                                | cuttlefish      | BrianLPL27                           | BrianLPL27 wrote initial view (PR #59, closed); cuttlefish rewrote from scratch with partials (PR #76) |
| 23 | Items Sort & Filter                              | cuttlefish      | BrianLPL27, massivemoron345          | BrianLPL27 added keyword filter (2 files); cuttlefish rewrote with collapsible UI + sort scopes (PR #77); massivemoron345 fixed filter bugs (#85, #86) |
| 24 | Like Button (Turbo Frame)                        | cuttlefish      | —                                    | PR #57; heart toggle, like count, no full-page reload                 |
| 25 | Item View Count                                  | cuttlefish      | —                                    | PR #57; increment on show, displayed on card                          |
| 26 | Landing Page                                     | cuttlefish      | —                                    | PR #80; hero, how-it-works, featured items for unauthenticated users  |
| 27 | Production Deploy (PostgreSQL + Solid Trifecta)  | cuttlefish      | —                                    | PRs #81, #84; Postgres, SolidCache/Queue/Cable, Tailscale Funnel     |
| 28 | Test Coverage                                    | cuttlefish      | massivemoron345, LAM KEI HUNG        | 187 unit + 45 system tests, 91.78% coverage; massivemoron345: auth/karma/item tests (#48, #51); LAM KEI HUNG: sign-up/mailer tests (#63, #74, #78) |
