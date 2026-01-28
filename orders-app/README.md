# Orders Service (Rails API)

Creates and queries orders. On create, it validates the customer by calling Customers Service (HTTP) and publishes an `orders.created` event to RabbitMQ.

## Responsibilities
- Create orders (REST API).
- Query orders by `customer_id`.
- Validate customer existence via Customers Service.
- Publish `orders.created` events to RabbitMQ.

## API
- POST `/orders`
  - Body (JSON or form): `customer_id`, `product_name`, `quantity`, `price`, `status`.
  - Success 201 (JSON:API): serialized order.
  - Errors (JSON:API):
    - 400 when `customer_id` is missing.
    - 422 when customer does not exist or validations fail.
    - 502 when Customers Service is unavailable.
    - 500 when publish to RabbitMQ fails.
- GET `/orders?customer_id=:customer_id`
  - Returns all orders for the given customer (JSON:API list).
- GET `/up`
  - Liveness endpoint; returns 200 if the app booted without exceptions.

## Domain Model

### Order
- Attributes:
  - `id` (integer)
  - `customer_id` (integer, required)
  - `product_name` (string, required)
  - `quantity` (integer, required, > 0)
  - `price` (decimal, required, >= 0)
  - `status` (string, required)
  - `created_at` (datetime)
- Validations: presence for `customer_id`, `product_name`, `status` ; numericality for `quantity` (> 0) and `price` (>= 0).
- Serialization: JSON:API via `OrderSerializer` (price as string; `created_at` ISO8601).

## Services

### Orders::CreateOrder
- Input: `params` hash with `customer_id`, `product_name`, `quantity`, `price`, `status`.
- Flow:
  1) Ensures `customer_id` is present.
  2) Calls `CustomerServiceClient.ensure_exists!` to validate the customer.
  3) Creates the order (`Order.create!`).
  4) Publishes the event via `OrderCreatedPublisher`.
- Raises:
  - `Orders::CreateOrder::CustomerNotFound` when Customers Service returns 404.
  - `CustomerServiceClient::Unavailable` when HTTP fails or times out.
  - `OrderCreatedPublisher::PublishError` when publish fails.

### CustomerServiceClient
- Reads `CUSTOMER_SERVICE_URL` (defaults to `http://customer-service:3001`).
- GET `/customers/:id`:
  - 200: returns true.
  - 404: raises `Orders::CreateOrder::CustomerNotFound`.
  - Other / network errors: raises `Unavailable`.

### OrderCreatedPublisher
- Reads `RABBITMQ_URL`.
- Publishes to direct exchange `orders.events` with routing key `orders.created`.
- Payload:
  ```json
  {
    "event_id": "uuid",
    "order": { "id": 1, "customer_id": 1, "product_name": "...", "quantity": 1, "price": "12.34", "status": "created", "created_at": "..." }
  }
  ```
- Raises `PublishError` on failure.

## Configuration
- Environment variables:
  - `DATABASE_URL` (PostgreSQL connection string)
  - `CUSTOMER_SERVICE_URL` (Customers Service base URL)
  - `RABBITMQ_URL` (RabbitMQ connection string)
  - `RAILS_ENV`, `RAILS_LOG_TO_STDOUT`, `SECRET_KEY_BASE` (prod)
- Production specifics:
  - Cache store: Solid Cache with the primary DB.
  - Active Job: Solid Queue mapped to the primary DB.
  - Action Cable: `async` adapter.

## Database
- Migration: `create_orders` with customer/order fields and defaults.

## Run locally (Docker)
From the monorepo root:
- All services: `docker compose up --build`
- Orders only + deps: `docker compose up --build order-service order-db rabbitmq customer-service`
- Health: `curl http://localhost:3000/up`

## Testing
- Unit (RSpec): `docker compose exec order-service bundle exec rspec`
  - Request specs: create (201), missing customer (422), list by customer (200), missing `customer_id` (400).
  - Publisher is stubbed in tests; Customers HTTP is stubbed via WebMock.
- Integration/E2E (monorepo):
  - `docker compose -f docker-compose.yml -f docker-compose.integration.yml run --rm e2e`
  - Scenario: boot both services, create an order, Customers increments `orders_count` via event.

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

Notes:

* Ports/credentials come from `.env` (5433/5434 by default).
* If you change DB names, keep the `_test` suffix for the test environment.
* For fish shell, replace `export ...` with `set -x ...`.

## Test Coverage

- Tooling: uses SimpleCov to collect coverage and generate an HTML report.
- Report: after running with coverage, open `coverage/index.html` in a browser.
- Enable coverage run:
  - `COVERAGE=true bundle exec rspec`

## Code Style

- Linting/formatting: uses RuboCop for Ruby conventions.
- Run linter: `bundle exec rubocop`
- Optional autocorrect: `bundle exec rubocop -A` (review changes carefully).

## Operations
- Migrate: `docker compose exec order-service bin/rails db:migrate`
- Reset DB: `docker compose down -v --remove-orphans && docker compose up -d --build`
- Logs: `docker compose logs -f order-service`
