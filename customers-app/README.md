# Customers Service (Rails API)

This service exposes customer information and keeps `orders_count` updated by consuming `orders.created` events from RabbitMQ.

## Responsibilities
- Provide customer data to other services (Orders Service) via HTTP.
- Maintain `orders_count` for each customer (event‑driven update).
- Seed a predefined customer base (no write endpoints required).

## API
- GET `/customers/:id`
  - Path params: `id` (integer).
  - Success 200 (JSON:API):
    ```json
    {
      "data": {
        "type": "customer",
        "id": "1",
        "attributes": {
          "customer_name": "Ana",
          "address": "Street 1",
          "orders_count": 2
        }
      }
    }
    ```
  - Not found 404 (JSON:API error):
    ```json
    { "errors": [ { "status": "404", "title": "Not Found", "detail": "Record not found" } ] }
    ```
- GET `/up`
  - Liveness endpoint: returns 200 if the app booted without exceptions.

## Domain Models

### Customer
- Purpose: represents a customer and their `orders_count`.
- Attributes:
  - `id` (integer)
  - `customer_name` (string, required)
  - `address` (string, required)
  - `orders_count` (integer, required, default `0`, `>= 0`)
- Validations: presence of `customer_name` and `address`; `orders_count` is integer and `>= 0`.
- Serialization: JSON:API via `CustomerSerializer` with attributes `customer_name`, `address`, `orders_count`.

### ProcessedEvent
- Purpose: idempotency ledger of events already processed by the consumer.
- Attributes: `id` (integer), `event_id` (string, required, unique), `processed_at` (datetime, required).
- Validations: presence + uniqueness of `event_id`, presence of `processed_at`.

## Consumer and Services

### Customers::OrdersCreatedHandler.call(payload)
- Parameters: `payload` (Hash) with `event_id` (string) and `order.customer_id` (integer) or `customer_id` (integer).
- Behavior:
  - If `customer_id` is missing, logs a warning and returns.
  - Creates `ProcessedEvent` (idempotent; ignores duplicates).
  - Increments `Customer.orders_count` for that `customer_id`.
- Returns: `nil` (effects are in DB and logs).

### bin/consumer
- Reads `RABBITMQ_URL` and connects to RabbitMQ with retries.
- Declares direct exchange `orders.events` and queue `customer.orders.created`.
- Binds with routing key `orders.created`, parses JSON, delegates to `OrdersCreatedHandler`.
- Acks on success/invalid JSON; nacks (requeue) on unexpected errors.

## Configuration
- Environment variables:
  - `DATABASE_URL` (PostgreSQL)
  - `RABBITMQ_URL` (RabbitMQ)
  - `RAILS_ENV`, `RAILS_LOG_TO_STDOUT`, `SECRET_KEY_BASE` (prod)
  - `JOB_CONCURRENCY` (optional, Solid Queue workers inside Puma)
- Production specifics:
  - Cache store: Solid Cache with the primary DB (see `config/cache.yml`).
  - Active Job: Solid Queue mapped to the primary DB.
  - Action Cable: `async` adapter (no DB connection required).

## Database
- Migrations: `create_customers`, `create_processed_events` (unique index on `event_id`).
- Seeds: loads a small list of customers idempotently on startup.

## Run locally (Docker)
From the monorepo root:
- All services: `docker compose up --build`
- Only Customers + deps: `docker compose up --build customer-service customer-db rabbitmq`
- Health check: `curl http://localhost:3001/up`

## Testing
- Unit (RSpec): `docker compose exec customer-service bundle exec rspec`
  - Request specs: 200 with customer JSON:API payload; 404 with JSON:API error.
  - Helpers: `spec/support/json_helpers.rb` (`json_body`, `json_data`, `json_errors`).
- Integration/E2E (monorepo):
  - `docker compose -f docker-compose.yml -f docker-compose.integration.yml run --rm e2e`
  - Scenario: boot both services, create an order, verify `orders_count` increments via the event.

## Local unit tests (DB via Docker)

You only need Postgres for local unit tests.
RabbitMQ is not required; specs stub external calls.

### 1) Start databases (once per session)
```bash
docker compose up -d order-db customer-db
```

### 2) Run Customers specs

```bash
cd customers-app
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
- Threshold: CI enforces 85% minimum coverage.
  Local runs with `COVERAGE=true` also enforce 85%.
- Scope: coverage tracks only controllers and models.

## Code Style

- Linting/formatting: uses RuboCop for Ruby conventions.
- Run linter: `bundle exec rubocop`
- Optional autocorrect: `bundle exec rubocop -A` (review changes carefully).

## Operations
- Migrations: `docker compose exec customer-service bin/rails db:migrate`
- Seeds: `docker compose exec customer-service bin/rails db:seed`
- Reset: `docker compose down -v --remove-orphans && docker compose up -d --build`

## Logging & Errors
- Structured logs use keys from `app/constants.rb` (e.g., `not_found`, `ord_missing_cust`, `ord_processed`, `ord_already`).
- Error payloads follow JSON:API; `errors[0].status` is a string (e.g., "404").
