# Customers Service (Rails API)

This service exposes customer information and keeps `orders_count` updated by
consuming `orders.created` events from RabbitMQ.

## Responsibilities
- Provide customer data to other services (Orders Service) via HTTP.
- Maintain `orders_count` for each customer (event-driven update).
- Seed a predefined customer base (no customer creation required).

## Endpoints
- `GET /customers/:id`
  - Returns: `customer_name`, `address`, `orders_count`

## Environment variables
- `DATABASE_URL` (PostgreSQL connection string)
- `RABBITMQ_URL` (RabbitMQ connection string)

Example:
- `DATABASE_URL=postgres://postgres:postgres@customer_db:5432/customers_db`
- `RABBITMQ_URL=amqp://app:app_password@rabbitmq:5672`

## Run locally (Docker recommended)
From the monorepo root:
- Start everything:
  - `docker compose up --build`
- Or only this service:
  - `docker compose up --build customer_service customer_db rabbitmq`

## Database setup
In Docker, the service runs `db:prepare` and `db:seed` on startup.

If running manually inside the container:
- `docker compose exec customer_service rails db:prepare db:seed`

## Tests
- `docker compose exec customer_service bundle exec rspec`

## Notes
- This service includes a separate consumer process (`customer-consumer`) that
  listens to `orders.created` events and updates `orders_count`.
