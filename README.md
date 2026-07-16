# Flashforge

A Rails 7 + PostgreSQL + Redis sample project for learning API development, checkout flow, vouchers, caching, and flash sale concurrency.

## Features

- Dockerized Rails app with PostgreSQL and Redis
- User, product, order, voucher, and flash sale APIs
- Product checkout with stock reduction
- Voucher-based discount checkout
- Redis caching for product listing
- Flash sale checkout using pessimistic locking to prevent race conditions

## Tech Stack

- Ruby 3.3.5
- Rails 7.2
- PostgreSQL 16
- Redis 7
- Docker Compose

## Run with Docker

Start the services:

```bash
docker compose up -d --build
```

Run database setup:

```bash
docker compose exec web bundle exec rails db:create db:migrate db:seed
```

## API Endpoints

### Users

```bash
curl http://localhost:3000/api/users
```

### Products

```bash
curl http://localhost:3000/api/products
```

### Checkout

Normal checkout:

```bash
curl -X POST http://localhost:3000/api/products/1/checkout \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "user_id=1&quantity=2"
```

Checkout with voucher:

```bash
curl -X POST http://localhost:3000/api/products/2/checkout \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "user_id=1&quantity=1&voucher_code=DISCOUNT10"
```

Checkout with flash sale:

```bash
curl -X POST http://localhost:3000/api/products/1/checkout \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "user_id=1&quantity=5&use_flashsale=true"
```

### Orders

```bash
curl http://localhost:3000/api/orders
```

### Vouchers

List vouchers:

```bash
curl http://localhost:3000/api/vouchers
```

Create voucher:

```bash
curl -X POST http://localhost:3000/api/vouchers \
  -H "Content-Type: application/json" \
  -d '{"voucher":{"code":"NEW10","discount":0.1,"max_usage":10,"expired_at":"2026-12-31T00:00:00Z"}}'
```

### Flash Sales

List flash sales:

```bash
curl http://localhost:3000/api/flash_sales
```

Create flash sale:

```bash
curl -X POST http://localhost:3000/api/flash_sales \
  -H "Content-Type: application/json" \
  -d '{"flashsale":{"product_id":1,"flash_price":9.99,"flash_stock":50,"start_at":"2026-07-16T00:00:00Z","end_at":"2026-07-16T23:59:59Z"}}'
```

## Race Condition Demo

A flash sale race test script is available:

```bash
bash /home/kurarisu/flashforge/scripts/test_flashsale_race.sh
```

This script sends many concurrent requests to demonstrate that pessimistic locking prevents overselling.

## Logging

To inspect flash sale checkout logs:

```bash
docker compose logs -f web
```

## Notes

- The project is intended for learning and experimentation.
- Redis is used for caching product list responses.
- Flash sale checkout uses pessimistic locking to protect shared stock during concurrent requests.

