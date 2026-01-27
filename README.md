# Ecommerce-Services

Monorepo with two Ruby on Rails API microservices: Orders and Customers, using PostgreSQL and RabbitMQ.

## Services
- orders-app: creates/queries orders, calls Customers over HTTP to validate and publishes `orders.created` events to RabbitMQ.
- customers-app: exposes customer data and consumes `orders.created` to keep `orders_count` updated.

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
  - `docker compose up -d order_db customer_db rabbitmq`
- Start services:
  - `docker compose up --build customer_service order_service`
- Full stack:
  - `docker compose up --build`
