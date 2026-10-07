# Elephanto

Elephanto is a Ruby on Rails flashcard application for organizing study material and reviewing it through spaced repetition. Users create personal decks, write questions and answers, and study cards selected by their scheduled due dates.

The application combines an FSRS scheduler with a guided review queue, persisted study sessions, and a statistics dashboard. It uses server-rendered views, Hotwire interactions, Tailwind CSS, PostgreSQL, and database-backed background jobs. The interface currently defaults to Brazilian Portuguese.

## About the Project

Elephanto turns a collection of study notes into a repeatable review workflow. After registering, confirming an email address, and completing a profile, a user can create decks and add flashcards. Each deck groups related material and shows how many cards are new, learning, in review, or relearning.

A study session selects due cards from a deck. The user reveals each answer and rates recall; the scheduler updates the card's state and next due date. Session progress and elapsed time are recorded, while the statistics page summarizes study activity and pending reviews.

## Features

- Registration, email confirmation and resend, sign-in/sign-out, password recovery, password changes, and account deletion.
- Profiles with biographies, locations, avatars, and cover uploads through Active Storage.
- Personal deck and flashcard creation, editing, and deletion; deck covers, favorites, recent-deck filtering, and paginated card lists.
- Formatted flashcard answers through a Stimulus editor, with an HTML tag allowlist when rendering answers.
- FSRS scheduling with four recall ratings and a guided review queue.
- Study-session progress, completion summaries, and duration tracking.
- Statistics for decks, cards, sessions, study time, due cards by deck, and sessions by day.
- Light/dark theme switching and Turbo Stream updates for favorites and settings.
- Admin-restricted dashboard and log viewer.

Profile settings also store daily new-card and review limits. These preferences are not yet applied to the review queue.

## Spaced Repetition

The active implementation uses the `fsrs` gem from `open-spaced-repetition/rb-fsrs`, locked to version **0.9.0** and a Git revision in `Gemfile.lock`. `Flashcard#rate!` calls `Fsrs::Scheduler.new` with the library defaults; the application does not supply custom scheduler parameters or train weights from review history.

Each flashcard persists the library's serialized card state in the PostgreSQL `json` column `fsrs_state`. The model normalizes timestamps and missing state, exposes scopes for the four learning states, and queries due cards in SQL. The review screen uses `review_options` to show scheduling outcomes for **Again**, **Hard**, **Good**, and **Easy**.

`FlashcardsController#start_review` selects due cards from the deck, orders them by the stored due value, and creates a `ReviewSession`. The queue is held in the Rails session. `ReviewSessionService` persists each rating through the model, removes the current card, and puts **Again** cards at the end of the queue without increasing the completed-card count. This in-session requeue is immediate; it does not wait for the newly scheduled FSRS due time. When the queue empties, the service records completion, duration, and the deck's last review time.

The migrations document an evolution from SM-2-era fields: `MigrateSm2ToFsrs` removes `efactor` and adds stability/difficulty fields, and a later migration replaces the separate scheduling fields with `fsrs_state`.

## Tech Stack

| Area | Technology |
| --- | --- |
| Runtime | Ruby **3.3.4**; Bundler **2.7.2** in the lockfile |
| Framework | Rails **8.0.2** |
| Database | PostgreSQL; CI uses PostgreSQL **16** |
| Web server | Puma |
| Frontend | ERB, Turbo, Stimulus, Importmap, Propshaft |
| Styling | Tailwind CSS **4.1.11** via `tailwindcss-ruby` and `tailwindcss-rails` |
| Scheduling | `fsrs` **0.9.0** from a pinned Git revision |
| Authentication | Rails authentication concern, persisted sessions, `has_secure_password`, bcrypt |
| Background work | Active Job with Solid Queue in development and production |
| Cache / Cable | Solid Cache and Solid Cable in production; memory cache and async Cable in development |
| Uploads | Active Storage with local disk storage |
| Charts / Pagination | Chartkick, Chart.js, Groupdate, Kaminari |
| Tests / Quality | Minitest, minitest-rails, SimpleCov, RuboCop, Brakeman, Importmap audit |
| Deployment configuration | Capistrano, RVM, Passenger |

JavaScript is loaded through Importmap. There is no `package.json` or npm/Yarn installation step. `.tool-versions` also lists Node.js 22.11.0, but the supported development scripts do not invoke Node.js.

## Architecture / Domain

| Component | Responsibility |
| --- | --- |
| `User` | Credentials, email verification, account validation, and ownership of decks and a profile. |
| `Session` / `Current` | Database-backed login sessions and access to the current user through a signed cookie. |
| `Profile` | Personal information, attached images, and validated study-limit preferences. |
| `Deck` | Groups cards and review sessions; stores presentation metadata and favorite status. |
| `Flashcard` | Question/answer content, FSRS state, due/state queries, and scheduling after ratings. |
| `ReviewSession` | Study-session totals, reviewed count, start/completion timestamps, and duration. |
| `ReviewSessionService` | Queue advancement, Again requeues, and completion bookkeeping. |
| `ConfirmationEmailJob` | Sends account-confirmation email asynchronously through Action Mailer. |

Authentication is implemented in the application rather than through Devise. Sign-in requires email verification, is rate-limited, and stores a signed, HTTP-only session cookie. Confirmation links expire after one day, and resend requests have a five-minute cooldown. Password recovery uses Rails password-reset tokens; its email is currently sent synchronously.

Public landing pages and authenticated application routes are separated by host/subdomain constraints. The local application uses `app.localhost`; account-owned resources are generally resolved through the current user. Action Cable authenticates connections using the persisted login session, although no application-specific channels or broadcast features are present.

## Getting Started

### Prerequisites

- Ruby **3.3.4**, with Bundler **2.7.2** matching `Gemfile.lock`.
- A running PostgreSQL server; PostgreSQL **16** matches CI. No minimum database version is declared.
- PostgreSQL client development libraries for the `pg` gem (`libpq-dev` is installed in CI).
- Git and network access to install the Git-sourced FSRS gem and other dependencies.
- A modern browser; the application uses Rails' modern-browser restriction.
- SMTP access for email confirmation and password recovery when using the registration flow.

### Installation

From the repository root, configure the environment variables below and run:

```sh
bin/setup --skip-server
```

`bin/setup` checks/installs gems with Bundler, runs `bin/rails db:prepare`, and clears logs and temporary files. Without `--skip-server`, it also launches `bin/dev`. You can install gems separately with `bundle install`.

### Database setup

The database configuration defines `elephanto_development`, `elephanto_development_queue`, and `elephanto_test`. Your PostgreSQL role needs access to these databases and permission to create them when using the setup task.

The setup script runs this command; use it again after pulling schema changes:

```sh
bin/rails db:prepare
```

Rails prepares the configured databases from the schemas/migrations and loads seeds when initializing a new database. The repository includes separate schemas for Solid Queue, Solid Cache, and Solid Cable.

The explicit seed command is:

```sh
bin/rails db:seed
```

The seeds contain sample users, profiles, five decks, fifty flashcards, and avatar files in `db/seed_images`. They include verified sample accounts and administrator accounts with fixed development passwords. Inspect `db/seeds.rb` for local sample-account details; use these seeds only with a disposable local database.

Seeds use natural keys and associations and can be rerun without duplicating sample records, replacing existing passwords, or resetting card scheduling state. Demo data is loaded only in development and test; production and other environments skip it.

### Environment variables

Export variables in your shell so both the web process and job worker inherit them. `dotenv-rails` loads in production; a development `.env` file is not automatically loaded by that gem. `bin/dev` uses Foreman, but exporting variables also covers `bin/setup` and a separately started `bin/jobs`.

| Variable | Purpose / requirement |
| --- | --- |
| `ELEPHANTO_USERNAME` or `PGUSER` | PostgreSQL role. Defaults to `postgres` locally when neither is set. |
| `ELEPHANTO_PASSWORD` or `PGPASSWORD` | Local/test database password, if required by PostgreSQL authentication. |
| `ELEPHANTO_HOST` or `PGHOST` | Database host; defaults to `localhost`. |
| `APP_HOST` | Generated-link host. Set to `app.localhost` locally so email links reach the application routes. |
| `APP_PROTOCOL` | Generated-link protocol; defaults to `http`. |
| `APP_PORT` | Generated-link port. Set to `4000` for the default `bin/dev` server. |
| `SMTP_USERNAME`, `SMTP_PASSWORD` | Credentials for the configured Brevo SMTP relay; needed for confirmation and recovery emails. Tests use the test delivery adapter. |
| `MAPBOX_PUBLIC_KEY` | Optional public browser token for profile location autocomplete. Without it, location can be entered manually. |
| `PORT` | Optional web-port override; `bin/dev` defaults to `4000`. Keep `APP_PORT` in sync. |

For local link generation:

```sh
export APP_HOST=app.localhost
export APP_PROTOCOL=http
export APP_PORT=4000
```

The location form calls Mapbox from the browser. A separate `locations/search` endpoint queries OpenStreetMap Nominatim without an API key; the current autocomplete controller uses Mapbox. Layouts also load external fonts/icons and some decorative images.

For production, `config/database.yml` specifically reads `ELEPHANTO_USERNAME` and `ELEPHANTO_DATABASE_PASSWORD` for database credentials. Rails' credential decryption key is provisioned outside Git; Capistrano links `config/master.key`. Configure `APP_HOST`, `APP_PROTOCOL`, and any necessary `APP_PORT` explicitly because the default-URL initializer overrides environment-level URL options. Never commit credentials or populated environment files.

### Running the application

Start the Rails server and Tailwind watcher together:

```sh
bin/dev
```

`bin/dev` installs Foreman if missing and runs the two processes in `Procfile.dev`. Open the landing page at `http://localhost:4000` and the application at `http://app.localhost:4000`. These hostnames matter because of the route constraints.

Start the Solid Queue worker in a second terminal with the same exported environment:

```sh
bin/jobs
```

The worker is not included in `Procfile.dev`; it is needed for queued confirmation emails. Password-reset emails use synchronous delivery. You can use a verified seed account to explore locally without sending confirmation email, or register with working SMTP credentials and confirm the emailed link.

For a one-off CSS build:

```sh
bin/rails tailwindcss:build
```

No separate JavaScript bundler process is configured.

### Running the test suite

With PostgreSQL available and the local/test database credentials exported:

```sh
RAILS_ENV=test bin/rails db:prepare
bin/rails test
```

CI additionally runs:

```sh
bin/rails test:system
```

System tests use Selenium with headless Chrome. Install Chrome to run them; CI provisions it automatically. The tests cover sign-in/deck access and starting a review with answer reveal and recall ratings.

## Testing

The suite uses Minitest and `minitest-rails`, with fixtures, spec-style tests, integration/controller tests, job assertions, and mailer tests. SimpleCov is initialized in `test/test_helper.rb` and writes reports to `coverage/`; no coverage percentage is claimed here.

Existing tests cover account and profile validation, login and verification behavior, confirmation expiry/resend rules, password email delivery, deck operations, access checks, flashcard CRUD, FSRS-state normalization, due-card selection, guarded review navigation, Again requeues, and session completion. Statistics and admin pages have request coverage. Regression tests cover favorite ownership, user-scoped empty states, repeatable seeds, and protection against production demo seeding.

### Development test workflow

Guard is an optional development convenience:

```sh
bundle exec guard
```

`Guardfile` maps changes to Ruby application files to their matching tests, reruns controller tests when `ApplicationController` changes, watches mailer templates and test files, and reruns tests when `test_helper.rb` changes. It does not replace the canonical Rails test commands used in CI.

Run a single file or filter test names with Rails:

```sh
bin/rails test test/controllers/decks_controller_test.rb
bin/rails test test/controllers/decks_controller_test.rb --name '/favorite/'
```

The existing `minitest-focus` gem also supports placing `focus` immediately before a test definition during development. Remove focus markers before sharing changes. To ignore any focus markers and run the complete suites:

```sh
bin/rails test --no-focus
bin/rails test:system --no-focus
```

GitHub Actions configures PostgreSQL 16, runs database preparation and the test commands, and checks Ruby/JavaScript dependencies and style with:

```sh
bin/brakeman --no-pager
bin/importmap audit
bin/rubocop -f github
```

## Deployment

The supported deployment configuration uses **Capistrano, RVM, and Passenger** on a Linux server, with PostgreSQL. The admin log viewer includes Nginx and Passenger log sources; server provisioning and Nginx configuration are managed outside this repository.

Production deploys the `main` branch. Set `DEPLOY_HOST` and `DEPLOY_USER` in the deploying machine's environment; the stage file contains no server address or operator account. After provisioning the server and shared configuration, the Capistrano command is:

```sh
bundle exec cap production deploy
```

Capistrano runs Bundler, asset compilation, migrations, and Passenger restart tasks. Its shared files include `config/database.yml`, `.env`, and `config/master.key`; shared directories preserve uploads and runtime files across releases. Production uses HTTPS, SMTP, local-disk Active Storage, and separate PostgreSQL databases for primary data, Solid Queue, Solid Cache, and Solid Cable.

Provision a Solid Queue worker using `bin/jobs` with the production environment and maintain persistent storage/backups for uploaded files. Worker service management is external to the repository. Staging is not currently supported.

## Screenshots

Screenshots have not yet been added. Suggested portfolio captures:

| Screen | Placeholder |
| --- | --- |
| Deck library / dashboard | _Capture pending_ |
| Deck details / flashcards | _Capture pending_ |
| Review session with Again / Hard / Good / Easy | _Capture pending_ |
| Statistics dashboard | _Capture pending_ |

## What I Learned / Technical Highlights

- **Domain modeling:** separate account, profile, deck, flashcard, login-session, and study-session responsibilities, with associations and dependent cleanup.
- **Scheduler integration:** persist FSRS state as JSON, normalize deserialized timestamps, and use PostgreSQL JSON queries to select due cards and learning states.
- **Review-flow design:** separate scheduling from queue bookkeeping, guard navigation against out-of-order requests, and test Again handling without inflating progress.
- **Authentication:** implement bcrypt-backed credentials, signed session cookies, email verification with expiry/cooldown checks, and Rails password-reset tokens.
- **Progressive interactions:** use server-rendered views, Turbo Streams, and focused Stimulus controllers for formatting, themes, uploads, and autocomplete.
- **Background delivery and operations:** move confirmation email into Active Job/Solid Queue, preserve uploaded files across Capistrano releases, and configure database-backed production cache/Cable.
- **Evolution and regression testing:** retain migration evidence of scheduling changes and add tests around state normalization and the session lifecycle.

## Project Status

Elephanto is maintained as a technical portfolio project. This README provides a local evaluation workflow; no hosted demo is linked. The project demonstrates Rails domain modeling, scheduler integration, authentication, background jobs, and automated testing.

## License

No `LICENSE` file is present in the repository. A license has not been selected in this documentation update.
