## Bulk Transfer API

[![CI](https://github.com/D1353L/bulk_transfer_api/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/D1353L/bulk_transfer_api/actions/workflows/ci.yml)

An example API for processing bank transfers in bulk.

### Key Features

- **Atomicity**: All operations are executed within a database transaction to ensure all-or-nothing execution - either all transfers succeed or none are applied.
- **Idempotency**: Built-in idempotency key support enables safe retries without the risk of creating duplicate transfers.
- **Isolation**: Row-level locking on bank accounts prevents race conditions and ensures consistency under concurrent access.
- **Precision**: All monetary calculations use `BigDecimal` to maintain exact cent-level precision and avoid rounding errors.

### Future Improvements

- **Asynchronous Processing with Kafka**: Integrate Kafka to enable event-driven processing of bulk transfers, improving throughput and system decoupling.
- **Authentication & Authorization**: Implement security mechanisms to authenticate API clients and restrict access based on roles or permissions.

## How to Run

#### Using Docker

```bash
docker build . -t bulk_transfer_api
docker run -p 3000:3000 bulk_transfer_api
```

#### Locally

1. Install ruby 3.4.2
2. Prepare the database:

```bash
rails db:prepare
```

3. Start the Rails server:

```bash
rails s
```

### API Endpoints

- POST /transfers/bulk_create - Create multiple transfers in a single request.
- GET /api-docs - Swagger API docs.
