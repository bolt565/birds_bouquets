# Birds Bouquets — Coding Standards

## Architecture

- **Service objects** in `app/services/` for complex business logic (cart operations, etc.)
- **ViewComponents** in `app/components/` for reusable UI elements
- **No logic in views** — use helpers, components, and service objects
- **Thin controllers** — delegate to models, services, and jobs

## Models

- All models must `include InputSanitizable` to strip null bytes and control chars
- Prices are always stored as integers in cents (`price_cents`, `total_cents`, etc.)
- Use `#price_in_dollars` helpers for display — never compute cents/dollars in views
- Slugs are auto-generated from names with `before_validation :generate_slug`
- Soft deletes not used — guard destroys with order history checks instead

## Background Jobs

- Use `GoodJob` (PostgreSQL-backed, no Redis required)
- Job queues: `critical`, `mailers`, `default`, `cleanup`
- All jobs log at INFO level at start and end
- Email jobs go on the `mailers` queue

## Email

- All emails from `ApplicationMailer` with `from: "Birds Bouquets <hello@birdsbouquets.com>"`
- All sent emails logged to `email_logs` table via `EmailLogObserver`
- Use `deliver_later` for all non-critical emails
- Preview emails in development via `letter_opener`

## Payments

- Stripe PaymentIntents only — never store card data
- Webhook signature validation is mandatory — reject without valid `Stripe-Signature`
- Order status only transitions via `order.transition_to!(status)` — never set `status` directly in production flows

## SEO

- Every public page must call `seo_meta(title:, description:, url:)` in the controller
- Structured data methods live in `SeoHelper`
- All product images must have `alt_text` (validated at DB level)
- `loading="lazy"` on all non-hero images

## Security

- `rack-attack` for rate limiting (configured in `config/initializers/rack_attack.rb`)
- Admin routes protected by `require_admin!` before_action
- Stripe webhook endpoint has CSRF skipped — compensated by signature verification
- No sensitive data in logs

## Logging

- Log at `Rails.logger.info` for all business events
- Format: `[ClassName] action | key=value | key=value`
- Log errors at `Rails.logger.error` with context (user id, path)

## Testing

- Minitest with fixtures (no factories)
- Controller tests use `Devise::Test::ControllerHelpers`
- No mocking the database — use real test DB
- System tests use Capybara + headless Chrome
