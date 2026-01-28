# Ecommerce-Services

Monorepo with two Ruby on Rails API microservices: Orders and Customers, using PostgreSQL and RabbitMQ.

## Services
- orders-app: creates/queries orders, calls Customers over HTTP to validate and publishes `orders.created` events to RabbitMQ.
- customers-app: exposes customer data and consumes `orders.created` to keep `orders_count` updated.

### Service Docs
- Orders: `orders-app/README.md`
- Customers: `customers-app/README.md`

## Quickstart
- Run: `docker compose up --build`
- URLs: 
   - Orders `http://localhost:3000`
   - Customers `http://localhost:3001`
- RabbitMQ: `http://localhost:15672`
   - user: app
   - pass: app_password
- Postgres: Orders `5433`, Customers `5434`

## Run with Docker
- Infra only (DBs + RabbitMQ):
  - `docker compose up -d order-db customer-db rabbitmq`
- Start services:
  - `docker compose up --build customer-service order-service`
- Full stack:
  - `docker compose up --build`

## End-to-End (E2E) Testing
- Run the E2E flow (from repo root):
  - `docker compose -f docker-compose.yml -f docker-compose.integration.yml run --rm e2e`
- What it does:
  - Boots Orders, Customers, DBs, and RabbitMQ.
  - Waits for `/up` on both services.
  - Creates an order via Orders and verifies Customers increments `orders_count` (event-driven).
  - Script: `scripts/e2e.rb`.

## CI

- Unit tests: `.github/workflows/unit-tests.yml`
  - Runs on pull requests and pushes to `main`.
  - Matrix per app: `orders-app` and `customers-app` (two checks).
  - Enforces coverage >= 90% with SimpleCov (CI or `COVERAGE=true`).
  - Uses PostgreSQL service; external calls are stubbed in specs.
- Linting: `.github/workflows/rubocop.yml`
  - Separate job per app: `orders-app` and `customers-app` (two checks).
  - Runs on pull requests and pushes to `main`.
- E2E tests: `.github/workflows/e2e.yml`
  - Runs on pull requests and pushes to `main`.
  - Uses Docker Compose to boot both apps + DBs + RabbitMQ.

## How It Works (HTTP + RabbitMQ)

Order creation flow (arrows only):

```
Client -> Orders Service (POST /orders)
Orders Service -> Customers Service (GET /customers/:id)
Orders Service -> RabbitMQ (publish orders.created)
RabbitMQ -> Customers Consumer (consume orders.created -> increments orders_count)
```

- Orders service validates `customer_id` via HTTP to Customers.
- If valid, Orders creates the order and publishes `orders.created`.
- Customers consumer (`customers-app/bin/consumer`) consumes and increments `orders_count`.

## Run Locally

Quick option (all services):
- `docker compose up --build`
- URLs: Orders `http://localhost:3000`, Customers `http://localhost:3001`, RabbitMQ `http://localhost:15672`
- Health: `curl http://localhost:3000/up`, `curl http://localhost:3001/up`

Infra only, then services:
- Infra (DBs + RabbitMQ): `docker compose up -d order-db customer-db rabbitmq`
- Apps: `docker compose up --build customer-service order-service`

Manual end-to-end test:
- Create an order:
  - `curl -X POST http://localhost:3000/orders \
      -H 'Content-Type: application/json' \
      -d '{"customer_id":1,"product_name":"Keyboard","quantity":1,"price":"123.45","status":"created"}'`
- Verify customer `orders_count`:
  - `curl http://localhost:3001/customers/1` (check `data.attributes.orders_count`)

Automated E2E (script):
- `docker compose -f docker-compose.yml -f docker-compose.integration.yml run --rm e2e`
- Script: `scripts/e2e.rb` (waits for `/up`, creates an order, waits for `orders_count` increment).

## Local unit tests (DB via Docker)

You only need Postgres for local unit tests.
RabbitMQ is not required; specs stub external calls.

### 1) Start databases (once per session)
```bash
docker compose up -d order-db customer-db
```

### 2) Run Orders specs

```bash
cd orders-app
export DATABASE_URL="postgresql://user_admin:password_admin@localhost:5433/order_service_test"
bin/rails db:prepare RAILS_ENV=test
bundle exec rspec
```

### 3) Run Customers specs

```bash
cd ../customers-app
export DATABASE_URL="postgresql://user_admin:password_admin@localhost:5434/customer_service_test"
bin/rails db:prepare RAILS_ENV=test
bundle exec rspec
```

Notes:

* Ports/credentials come from `.env` (5433/5434 by default).
* If you change DB names, keep the `_test` suffix for the test environment.
* For fish shell, replace `export ...` with `set -x ...`.

## Test Coverage

- Tooling: uses SimpleCov to collect coverage and generate an HTML report.
- Report: after running with coverage, open `coverage/index.html` in a browser.
- Enable coverage run:
  - `COVERAGE=true bundle exec rspec`
 - Threshold: CI enforces 90% minimum coverage.
   Local runs with `COVERAGE=true` also enforce 90%.

## Code Style

- Linting/formatting: uses RuboCop for Ruby conventions.
- Run linter: `bundle exec rubocop`
- Optional autocorrect: `bundle exec rubocop -A` (review changes carefully).
