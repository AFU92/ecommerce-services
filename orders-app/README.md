# Orders Service (Rails API)

This service creates and queries orders. When an order is created, it fetches
customer details from Customers Service (HTTP) and publishes an `orders.created`
event to RabbitMQ.

## Responsibilities
- Create orders (REST API).
- Query orders by `customer_id`.
- Call Customers Service on order creation to validate/enrich customer data.
- Publish `orders.created` events to RabbitMQ.

## Endpoints
- `POST /orders`
  - Body: `customer_id`, `product_name`, `quantity`, `price`, `status`
- `GET /orders?customer_id=:customer_id`
  - Returns all orders for the given customer

## Environment variables
- `DATABASE_URL` (PostgreSQL connection string)
- `CUSTOMER_SERVICE_URL` (base URL for Customers Service)
- `RABBITMQ_URL` (RabbitMQ connection string)

Example:
- `DATABASE_URL=postgres://postgres:postgres@order-db:5432/orders_db`
- `CUSTOMER_SERVICE_URL=http://customer-service:3001`
- `RABBITMQ_URL=amqp://app:app_password@rabbitmq:5672`

## Run locally (Docker recommended)
From the monorepo root:
- Start everything:
  - `docker compose up --build`
- Or only this service:
  - `docker compose up --build order-service order-db rabbitmq customer-service`

## Database setup
If running manually inside the container:
- `docker compose exec order-service rails db:prepare`

## Tests
- `docker compose exec order-service bundle exec rspec`

## Notes
- On `POST /orders`, this service calls Customers Service over HTTP before saving
  and publishing the event.

## Operations
- Apply new migrations:
  - `docker compose exec order-service bin/rails db:migrate`
- Re-run seeds:
  - `docker compose exec order-service bin/rails db:seed`
- Reset database:
  - `docker compose down -v --remove-orphans`
  - `docker compose up -d --build`

### Useful commands
- Logs:
  - `docker compose logs -f order-service`
- Tests:
  - `docker compose exec order-service bundle exec rspec`
