# Birds Bouquets — Full MVP Plan

**Company:** Birds Bouquets
**Product:** E-commerce flower delivery platform
**Stack Base:** One-to-one mirror of ThetaPal (Ruby on Rails 7.2 / PostgreSQL / GoodJob / Stripe / Devise)
**Date:** June 2026

---

## 1. Company Overview & MVP Goals

Birds Bouquets is a modern flower e-commerce platform that lets anyone browse and purchase flowers — no account required. Registered customers get order history, saved addresses, and account management. Admins control the full product catalog, pricing, images, and orders from a dedicated dashboard.

### MVP Scope
- Public product catalog (guests can browse without logging in)
- Guest checkout + registered user checkout
- Order tracking (guest lookup by email + order number; logged-in users see full history)
- User accounts: email/password + Google OAuth, phone, shipping addresses
- Stripe payments
- Admin dashboard: product CRUD, category management, order management, customer view
- Transactional emails (order confirmation, shipped, admin alerts)
- SEO + GEO infrastructure from day 1

### Out of Scope (Post-MVP)
- Subscription flower boxes
- Loyalty/rewards program
- Real-time delivery tracking integration
- Multiple vendor/marketplace support
- Mobile app

---

## 2. Tech Stack (One-to-One with ThetaPal)

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | Ruby | 3.2.2 |
| Framework | Rails | 7.2.3 |
| Database | PostgreSQL | Latest |
| CSS | Tailwind CSS | 4.4 |
| Frontend | Hotwire (Turbo + Stimulus) | Turbo 2.x, Stimulus 1.3 |
| Components | ViewComponent | 4.6 |
| Background Jobs | GoodJob | 4.x |
| Authentication | Devise | 5.0 |
| OAuth | omniauth-google-oauth2 | 1.2 |
| Payments | Stripe | 13.x |
| Email | ActionMailer + SMTP | Rails built-in |
| Email Dev Preview | letter_opener | Latest |
| File Storage | Active Storage (local dev, S3/R2 prod) | Rails built-in |
| Rate Limiting | rack-attack | 6.8 |
| SEO | sitemap_generator | 6.3 |
| Security Scanner | brakeman | Latest |
| Linting | rubocop-rails-omakase | Latest |
| Testing | Minitest + Capybara + Selenium | Latest |
| Deployment | Docker + Render.com | Latest |
| Asset Pipeline | importmap-rails | Latest |
| Dev Environment | dotenv-rails | Latest |

---

## 3. Full Database Schema

### users
```
id, email, encrypted_password (Devise standard fields)
name                    string
phone                   string
avatar_url              string
provider                string        # 'google' for OAuth
uid                     string        # OAuth UID
admin                   boolean       default: false
stripe_customer_id      string
utm_source              string
utm_medium              string
utm_campaign            string
referring_url           string
landing_url             string
created_at, updated_at
```

### addresses
```
id
user_id                 bigint        not null, FK → users
name                    string        not null  # recipient name
line1                   string        not null
line2                   string
city                    string        not null
state                   string        not null
zip                     string        not null
country                 string        not null, default: 'US'
phone                   string
default                 boolean       default: false
label                   string        # e.g. "Home", "Office"
created_at, updated_at
```

### categories
```
id
name                    string        not null
slug                    string        not null, unique
description             text
position                integer       default: 0
active                  boolean       default: true
meta_description        string
meta_keywords           string
created_at, updated_at
```

### products
```
id
name                    string        not null
slug                    string        not null, unique
description             text          not null
price_cents             integer       not null
compare_at_price_cents  integer       # original/crossed-out price
category_id             bigint        FK → categories
in_stock                boolean       default: true
featured                boolean       default: false
position                integer       default: 0
meta_title              string
meta_description        string
meta_keywords           string
og_image_url            string
created_at, updated_at
```

### product_images
```
id
product_id              bigint        not null, FK → products
position                integer       default: 0
alt_text                string
# Active Storage attachment: image
created_at, updated_at
```

### orders
```
id
user_id                 bigint        nullable, FK → users  # null = guest order
order_number            string        not null, unique     # BB-2026-00001
status                  string        not null, default: 'pending'
  # pending | payment_pending | paid | processing | shipped | delivered | cancelled | refunded
email                   string        not null             # denormalized for guest orders
phone                   string
subtotal_cents          integer       not null
shipping_cents          integer       not null, default: 0
tax_cents               integer       not null, default: 0
total_cents             integer       not null
stripe_payment_intent_id string
stripe_charge_id        string
# Shipping address snapshot (denormalized so order history is accurate)
shipping_name           string        not null
shipping_line1          string        not null
shipping_line2          string
shipping_city           string        not null
shipping_state          string        not null
shipping_zip            string        not null
shipping_country        string        not null, default: 'US'
tracking_number         string
notes                   text          # customer notes
admin_notes             text
paid_at                 datetime
shipped_at              datetime
delivered_at            datetime
cancelled_at            datetime
cancellation_reason     string
created_at, updated_at
```

### order_items
```
id
order_id                bigint        not null, FK → orders
product_id              bigint        FK → products        # nullable (product may be deleted)
quantity                integer       not null
unit_price_cents        integer       not null             # price snapshot at time of order
product_name            string        not null             # name snapshot
created_at, updated_at
```

### email_logs
```
id
user_id                 bigint        nullable, FK → users
mailer_class            string
mailer_action           string
to_email                string
subject                 string
body_html               text
created_at
```

### blog_posts
```
id
title                   string        not null
slug                    string        not null, unique
body                    text          not null
excerpt                 text
meta_title              string
meta_description        string
meta_keywords           string
og_image_url            string
status                  string        default: 'draft'     # draft | published
published_at            datetime
author_name             string
created_at, updated_at
```

### app_settings
```
id
key                     string        not null, unique
value                   text
created_at, updated_at
```

### page_visits
```
id
user_id                 bigint        nullable
landing_url             string
referring_url           string
utm_source              string
utm_medium              string
utm_campaign            string
ip_address              string
user_agent              string
created_at
```

---

## 4. Architecture Directory Tree

```
birds_bouquets/
├── app/
│   ├── components/
│   │   ├── product_card_component.rb          # Product tile for catalog
│   │   ├── product_card_component.html.erb
│   │   ├── order_status_timeline_component.rb # Order progress tracker
│   │   └── cart_summary_component.rb          # Nav cart badge
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── concerns/
│   │   │   └── admin_required.rb
│   │   ├── pages_controller.rb                # Homepage, FAQ, static pages
│   │   ├── products_controller.rb             # Public catalog
│   │   ├── cart_controller.rb                 # Session-based cart
│   │   ├── checkout_controller.rb             # Checkout flow
│   │   ├── orders_controller.rb               # Order tracking + guest lookup
│   │   ├── stripe_webhooks_controller.rb
│   │   ├── contact_controller.rb
│   │   ├── blog_controller.rb
│   │   ├── legal_controller.rb
│   │   ├── users/
│   │   │   ├── registrations_controller.rb
│   │   │   ├── sessions_controller.rb
│   │   │   └── omniauth_callbacks_controller.rb
│   │   └── admin/
│   │       ├── base_controller.rb             # require_admin! before_action
│   │       ├── dashboard_controller.rb        # Metrics overview
│   │       ├── products_controller.rb         # Product CRUD
│   │       ├── categories_controller.rb
│   │       ├── orders_controller.rb           # Order management
│   │       ├── customers_controller.rb        # Customer list + detail
│   │       └── blog_posts_controller.rb
│   ├── helpers/
│   │   ├── application_helper.rb
│   │   └── seo_helper.rb                      # Meta tags + all JSON-LD methods
│   ├── jobs/
│   │   ├── application_job.rb
│   │   ├── send_order_notification_job.rb     # Queued after payment
│   │   ├── daily_order_digest_job.rb          # 8 AM daily admin summary
│   │   ├── cleanup_expired_carts_job.rb       # Nightly session cleanup
│   │   └── sitemap_refresh_job.rb             # Weekly sitemap regen
│   ├── mailers/
│   │   ├── application_mailer.rb
│   │   ├── order_mailer.rb                    # confirmation, shipped, delivered
│   │   ├── admin_mailer.rb                    # new_order, new_signup
│   │   └── contact_mailer.rb
│   ├── models/
│   │   ├── concerns/
│   │   │   └── input_sanitizable.rb           # Mirror ThetaPal's pattern
│   │   ├── application_record.rb
│   │   ├── user.rb
│   │   ├── address.rb
│   │   ├── category.rb
│   │   ├── product.rb
│   │   ├── product_image.rb
│   │   ├── order.rb
│   │   ├── order_item.rb
│   │   ├── blog_post.rb
│   │   ├── email_log.rb
│   │   ├── app_setting.rb
│   │   └── page_visit.rb
│   ├── services/
│   │   └── cart_service.rb                    # Encapsulates session cart logic
│   └── views/
│       ├── layouts/
│       │   ├── application.html.erb           # Authenticated user layout
│       │   ├── landing.html.erb               # Public marketing layout
│       │   ├── admin.html.erb                 # Admin sidebar layout
│       │   ├── mailer.html.erb
│       │   ├── mailer.text.erb
│       │   └── _seo_head.html.erb             # Full SEO partial
│       ├── pages/                             # home, faq, about
│       ├── products/                          # index, show
│       ├── cart/                              # show
│       ├── checkout/                          # address, payment, confirm
│       ├── orders/                            # show, lookup
│       ├── blog/                              # index, show
│       ├── legal/
│       ├── admin/
│       │   ├── dashboard/
│       │   ├── products/
│       │   ├── categories/
│       │   ├── orders/
│       │   ├── customers/
│       │   └── blog_posts/
│       └── shared/
│           ├── _flash.html.erb
│           ├── _nav.html.erb
│           └── _footer.html.erb
├── config/
│   ├── initializers/
│   │   ├── devise.rb
│   │   ├── good_job.rb                        # Queues + cron schedule
│   │   ├── rack_attack.rb
│   │   ├── stripe.rb
│   │   ├── content_security_policy.rb
│   │   └── email_log_observer.rb
│   ├── sitemap.rb
│   └── routes.rb
├── public/
│   ├── robots.txt                             # AI crawler allowlist
│   ├── llms.txt                               # GEO optimization
│   └── llms-full.txt
├── test/
│   ├── fixtures/
│   ├── models/
│   ├── controllers/
│   ├── mailers/
│   ├── jobs/
│   ├── system/
│   └── helpers/
├── CLAUDE.md
├── Dockerfile
├── render.yaml
├── Procfile.dev
└── .env.example
```

---

## 5. Routes Overview

```ruby
# config/routes.rb (planned structure)

root 'pages#home'

# Public
get '/faq',          to: 'pages#faq'
get '/about',        to: 'pages#about'
get '/contact',      to: 'contact#new'
post '/contact',     to: 'contact#create'
get '/privacy',      to: 'legal#privacy'
get '/terms',        to: 'legal#terms'
get '/returns',      to: 'legal#returns'
get '/blog',         to: 'blog#index'
get '/blog/:slug',   to: 'blog#show'

# Product catalog (public)
resources :products, only: [:index, :show]

# Cart
resource :cart, only: [:show] do
  post   :add_item
  delete :remove_item
  patch  :update_item
end

# Checkout (public - guest or logged in)
get  '/checkout',           to: 'checkout#address'
post '/checkout/address',   to: 'checkout#set_address'
get  '/checkout/payment',   to: 'checkout#payment'
post '/checkout/confirm',   to: 'checkout#confirm'
get  '/checkout/success',   to: 'checkout#success'

# Orders
resources :orders, only: [:show, :index]
get '/orders/lookup', to: 'orders#lookup'
post '/orders/find',  to: 'orders#find'

# Stripe webhooks
post '/stripe/webhooks', to: 'stripe_webhooks#create'

# User auth (Devise)
devise_for :users, controllers: {
  sessions:           'users/sessions',
  registrations:      'users/registrations',
  omniauth_callbacks: 'users/omniauth_callbacks'
}

# Account (authenticated)
namespace :account do
  resources :addresses
  get '/', to: 'dashboard#index'
end

# Admin (admin: true required)
namespace :admin do
  root to: 'dashboard#index'
  resources :products do
    member do
      patch :toggle_in_stock
      patch :toggle_featured
    end
  end
  resources :categories
  resources :orders do
    member do
      patch :update_status
      patch :add_tracking
    end
  end
  resources :customers, only: [:index, :show]
  resources :blog_posts
end
```

---

## 6. SEO & GEO Strategy (Built In from Day 1)

### Philosophy
Every page is built SEO-first. No page ships without a unique meta title, meta description, and canonical URL. Structured data is added at the model level (product → Product JSON-LD), not as an afterthought.

### seo_helper.rb Methods (mirror ThetaPal's pattern exactly)
- `seo_meta(title:, description:, url:, image:, keywords:)` — sets all head meta tags
- `organization_structured_data()` — Organization JSON-LD (homepage)
- `local_business_structured_data()` — LocalBusiness JSON-LD with hours/address (GEO win)
- `product_structured_data(product)` — schema.org/Product with price, availability, image
- `faq_structured_data(faqs)` — FAQPage JSON-LD for rich snippets
- `breadcrumb_structured_data(items)` — BreadcrumbList on all nested pages
- `article_structured_data(post)` — Article JSON-LD for blog posts

### robots.txt (AI Crawler Allowlist — mirror ThetaPal exactly)
```
User-agent: *
Allow: /

User-agent: GPTBot
Allow: /

User-agent: Claude-Web
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: Google-Extended
Allow: /

User-agent: Applebot-Extended
Allow: /

Sitemap: https://birdsbouquets.com/sitemap.xml
```

### GEO Files
- `/llms.txt` — 200-400 word plain-English description: what the store sells, service area, return policy, notable products, ordering process
- `/llms-full.txt` — Complete catalog descriptions, FAQ content, policy text, full product list with descriptions

### Sitemap (config/sitemap.rb)
- Static: homepage, /shop, /about, /faq, /contact, /blog
- Dynamic: all products (Product.in_stock), all categories (Category.active), all blog posts (BlogPost.published)
- Refresh: weekly cron via SitemapRefreshJob

### Target Keywords
| Priority | Keyword | Page |
|----------|---------|------|
| P1 | "buy flowers online" | Homepage |
| P1 | "fresh flower delivery" | Homepage |
| P1 | "flower bouquets" | /products |
| P2 | "[flower type] bouquet" | Individual product pages |
| P2 | "flower gift delivery" | Category pages |
| P3 | "flower care tips" | Blog posts |
| P3 | "best flowers for [occasion]" | Blog posts |

### Technical SEO Requirements
- All images require alt_text (validated at DB level: `validates :alt_text, presence: true` on ProductImage)
- Lazy loading on all product images (`loading="lazy"`)
- Mobile-first responsive design throughout
- Core Web Vitals focus: no heavy JS bundles (importmap + Hotwire only)
- Canonical URL on every page
- Open Graph + Twitter Card on all public pages

---

## 7. Epic Tickets — Full Build Sequence

Tickets are ordered for maximum build velocity: each ticket is independently testable before the next begins.

---

### EPIC 1: Foundation & Infrastructure

#### TICKET-001: Rails App Bootstrap
**Goal:** Create the Rails 7.2.3 app with full ThetaPal-equivalent stack.

**Tasks:**
- `rails new birds_bouquets --database=postgresql --css=tailwind --asset-pipeline=importmap`
- Add all gems to Gemfile (see tech stack table above)
- Configure Tailwind CSS with custom color palette (floral brand colors)
- Setup importmap with Turbo and Stimulus
- Configure `config/database.yml` for local + `DATABASE_URL` env var in production
- Create `Dockerfile` (mirror ThetaPal's multi-stage Docker pattern)
- Create `render.yaml` with web service, worker service, PostgreSQL database
- Create `Procfile.dev` with `web: bin/rails server` and `worker: bundle exec good_job start`
- Create `CLAUDE.md` with coding standards (service objects, no logic in views, log at INFO, InputSanitizable on all models)
- Create `.env.example` with all required env vars

**Acceptance Criteria:**
- [ ] `rails server` starts without errors on clean install
- [ ] `rails db:create db:migrate` completes successfully
- [ ] `bin/dev` runs both web and worker via Foreman/Overmind
- [ ] `docker build -t birds_bouquets .` succeeds locally
- [ ] `render.yaml` defines all three services (web, worker, db)

---

#### TICKET-002: GoodJob Configuration
**Goal:** Configure background job processing identical to ThetaPal's pattern.

**Tasks:**
- Create `config/initializers/good_job.rb` with:
  - `execution_mode: :external`
  - Queues: `default`, `mailers`, `critical`, `cleanup`
  - Concurrency limits per queue (default: 3, mailers: 2, critical: 1, cleanup: 1)
  - Cron schedule for: `daily_order_digest` (8 AM CT), `cleanup_expired_carts` (3 AM daily), `sitemap_refresh` (Sunday 2 AM)
- Create `app/jobs/application_job.rb` base class
- Verify GoodJob tables exist via migration

**Acceptance Criteria:**
- [ ] `bundle exec good_job start` runs without errors
- [ ] `GoodJob::Job.count` works in Rails console
- [ ] Enqueue a test job and verify it processes

---

### EPIC 2: Authentication & User Management

#### TICKET-003: User Model & Devise Setup
**Goal:** Full user authentication with email/password and Google OAuth.

**Tasks:**
- `rails generate devise:install` and configure `config/initializers/devise.rb`
- `rails generate devise User` — add custom fields migration: `name`, `phone`, `avatar_url`, `provider`, `uid`, `admin`, `stripe_customer_id`, UTM fields
- Create `app/controllers/users/sessions_controller.rb` (custom redirect on sign-in)
- Create `app/controllers/users/registrations_controller.rb` (collect name + phone on signup)
- Create `app/controllers/users/omniauth_callbacks_controller.rb` with `User.from_omniauth(auth)` class method
- Add `require_login!` and `require_admin!` before_action helpers to `ApplicationController`
- Configure omniauth-rails_csrf_protection

**Acceptance Criteria:**
- [ ] User can register with email, password, name, phone
- [ ] User can sign in with Google OAuth (dev credentials)
- [ ] `User.admin?` returns false by default
- [ ] `require_login!` redirects unauthenticated users to sign-in page
- [ ] Test: `test/models/user_test.rb` covers validations, `from_omniauth` upsert method

---

#### TICKET-004: User Address Management
**Goal:** Registered users can manage multiple shipping addresses.

**Tasks:**
- `rails generate model Address user:references name line1 line2 city state zip country phone default:boolean label`
- `app/controllers/account/addresses_controller.rb` (index, new, create, edit, update, destroy, set_default)
- Address form partial `app/views/shared/_address_form.html.erb` (reused in checkout)
- Validation: `name`, `line1`, `city`, `state`, `zip`, `country` required
- `before_destroy :check_no_orders` guard — cannot delete address referenced in orders
- Scopes: `Address.default_first`, `Address.for_user(user)`

**Acceptance Criteria:**
- [ ] Logged-in user can add address via `/account/addresses/new`
- [ ] Setting an address as default clears all others for that user
- [ ] Attempt to delete address shows error if used in an order
- [ ] Test: `test/models/address_test.rb` covers validations, default uniqueness
- [ ] Test: `test/controllers/account/addresses_controller_test.rb` covers auth guard

---

### EPIC 3: Product Catalog

#### TICKET-005: Category Model
**Goal:** Product categories for organization and navigation.

**Tasks:**
- `rails generate model Category name slug description:text position:integer active:boolean meta_description meta_keywords`
- Auto-generate slug from name using `before_validation :generate_slug`
- `include InputSanitizable` (create concern first, mirror ThetaPal)
- Scopes: `Category.active`, `Category.ordered`
- Seeds: Bouquets, Single Stems, Arrangements, Seasonal, Gift Sets

**Acceptance Criteria:**
- [ ] Slug auto-generates from name (`"Spring Bouquets"` → `"spring-bouquets"`)
- [ ] Duplicate slugs are rejected with validation error
- [ ] `Category.active.ordered` returns active categories by position ascending
- [ ] Test: `test/models/category_test.rb` covers slug, validations, scopes

---

#### TICKET-006: Product Model
**Goal:** Core product data model with SEO fields and pricing helpers.

**Tasks:**
- `rails generate model Product name slug description:text price_cents:integer compare_at_price_cents:integer category:references in_stock:boolean featured:boolean position:integer meta_title meta_description meta_keywords og_image_url`
- Auto-generate slug from name
- `include InputSanitizable`
- Price helpers: `price_in_dollars`, `compare_at_price_in_dollars`, `on_sale?`
- Scopes: `Product.in_stock`, `Product.featured`, `Product.by_category(category)`, `Product.ordered`
- Seed with 10 sample flower products across categories

**Acceptance Criteria:**
- [ ] `product.price_in_dollars` returns `"$24.99"` for `price_cents: 2499`
- [ ] `product.on_sale?` returns true when `compare_at_price_cents > price_cents`
- [ ] Slug is unique and URL-safe
- [ ] `Product.in_stock.featured.limit(6)` works for homepage query
- [ ] Test: `test/models/product_test.rb` covers all scopes and helpers

---

#### TICKET-007: Product Images (Active Storage)
**Goal:** Products have multiple orderable images stored via Active Storage.

**Tasks:**
- `rails active_storage:install`
- `rails generate model ProductImage product:references position:integer alt_text`
- `has_one_attached :image` on `ProductImage`
- Configure variants in `ProductImage`: `:thumbnail` (200x200 crop), `:card` (400x300), `:full` (800x600)
- `Product has_many :product_images, -> { order(:position) }`
- `Product#primary_image` helper returns first image or placeholder
- Configure Active Storage to use local disk in dev/test, set up config hooks for S3/R2 in prod

**Acceptance Criteria:**
- [ ] `product.product_images.first.image.variant(:card)` generates resized variant
- [ ] Products without images use a placeholder gracefully
- [ ] Position ordering works correctly
- [ ] Test: attach fixture image file and verify variant URL is generated

---

#### TICKET-008: Public Product Catalog
**Goal:** Anyone can browse products and view details — no login required.

**Tasks:**
- `ProductsController#index` — list in-stock products, filterable by `?category=slug`
- `ProductsController#show` — product detail page
- `ProductCardComponent` (ViewComponent) — image, name, price, "Add to Cart" button
- Product detail: carousel of images, description, price (with compare-at crossed out), category breadcrumb, "Add to Cart"
- SEO per product: `seo_meta` call in controller, Product JSON-LD in view
- BreadcrumbList JSON-LD: Home > Shop > [Category] > [Product]
- Use `landing.html.erb` layout for public pages (no auth nav)

**Acceptance Criteria:**
- [ ] `GET /products` returns 200 without any session/cookie
- [ ] `?category=bouquets` filters to only bouquet products
- [ ] Product show page has `<meta name="description">` with product's meta_description
- [ ] Product show page has `<script type="application/ld+json">` with Product schema
- [ ] Out-of-stock products show "Sold Out" badge and disabled "Add to Cart" button
- [ ] Test: `test/controllers/products_controller_test.rb` — public access, category filter

---

### EPIC 4: Shopping Cart & Checkout

#### TICKET-009: Shopping Cart (Session-Based)
**Goal:** Cart works for guests and logged-in users via session.

**Tasks:**
- `app/services/cart_service.rb` — encapsulates all cart operations on `session[:cart]`
  - `add_item(product_id, quantity)`, `remove_item(product_id)`, `update_quantity(product_id, qty)`, `items`, `total_cents`, `count`, `clear`
- `CartController` — show, add_item (POST), remove_item (DELETE), update_item (PATCH) — all respond to Turbo Streams
- Cart icon in nav with item count badge (Stimulus controller for live count)
- Cart page: item list with quantities, subtotal, "Proceed to Checkout" button

**Acceptance Criteria:**
- [ ] Guest can add item → cart count in nav increments (no page reload via Turbo)
- [ ] Cart persists across page loads (session)
- [ ] Out-of-stock product cannot be added (returns error toast)
- [ ] Updating quantity to 0 removes item
- [ ] Test: `test/services/cart_service_test.rb` — add, remove, update, total, clear

---

#### TICKET-010: Checkout Flow
**Goal:** Multi-step checkout collecting address then initiating payment.

**Tasks:**
- `CheckoutController` with steps: `address` → `payment` → `success`
- **Step 1 (Address):** Guest sees manual form; logged-in user sees saved addresses + "Use new address" option
- **Step 2 (Payment):** Order summary, Stripe Elements card input, "Place Order" button
- **On confirm:** Create `Order` + `OrderItems` from cart, generate `order_number`, set status to `payment_pending`
- **On payment success:** Set status to `paid`, clear cart, redirect to `/checkout/success`
- `Order.generate_order_number` — format `BB-YYYY-NNNNN` with zero-padded sequential number per year

**Acceptance Criteria:**
- [ ] Guest checkout completes with manual address + Stripe test card
- [ ] Logged-in user can select saved address
- [ ] `order_number` is unique (check: `Order.where(order_number: num).exists?`)
- [ ] Cart is cleared after successful order
- [ ] Test: `Order#generate_order_number` returns unique values, `OrderItem` stores price snapshot

---

#### TICKET-011: Stripe Payment Integration
**Goal:** Collect payments securely via Stripe PaymentIntents.

**Tasks:**
- `config/initializers/stripe.rb` — `Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY')`
- On checkout payment step: create `Stripe::PaymentIntent` server-side, return `client_secret` to front-end
- Front-end: Stripe.js Elements card form, confirm payment with `stripe.confirmCardPayment`
- `StripeWebhooksController#create` — verify signature, handle `payment_intent.succeeded` → update order status to `paid`, enqueue `SendOrderNotificationJob`
- Handle `payment_intent.payment_failed` → show error, order remains `payment_pending`
- Webhook endpoint exempt from CSRF protection

**Acceptance Criteria:**
- [ ] Test card `4242 4242 4242 4242` completes payment successfully
- [ ] Webhook endpoint validates Stripe-Signature header (reject invalid signatures with 400)
- [ ] `payment_intent.succeeded` event transitions order to `paid` status
- [ ] Declined card shows error message; cart is NOT cleared
- [ ] Test: `test/controllers/stripe_webhooks_controller_test.rb` with mock webhook payload and valid signature

---

### EPIC 5: Order Management

#### TICKET-012: Order Tracking (Customer-Facing)
**Goal:** Customers can find and track any order.

**Tasks:**
- `OrdersController#index` — logged-in user's order history (requires auth)
- `OrdersController#show` — order detail for logged-in user (own orders only)
- `OrdersController#lookup` (GET) — guest lookup form (email + order number)
- `OrdersController#find` (POST) — return order if email + order_number match
- `OrderStatusTimelineComponent` — visual progress: Placed → Paid → Processing → Shipped → Delivered
- Order detail: items + prices, shipping address, status, tracking number (as clickable link if present)

**Acceptance Criteria:**
- [ ] `/orders/lookup` accessible without login
- [ ] Correct email + order number returns order detail
- [ ] Wrong email or order number returns "not found" message (no info leak)
- [ ] Logged-in user cannot view another user's order (redirect with flash)
- [ ] Timeline correctly highlights the active step for each status
- [ ] Test: guest lookup with wrong email returns nothing, correct returns order

---

#### TICKET-013: Order Status State Machine
**Goal:** Controlled, auditable order status transitions.

**Tasks:**
- Implement state machine on `Order` model (manual with constants + transition method, no extra gem needed):
  - `VALID_TRANSITIONS = { pending: [:payment_pending], payment_pending: [:paid, :cancelled], paid: [:processing, :refunded], processing: [:shipped], shipped: [:delivered], delivered: [], cancelled: [], refunded: [] }`
- `order.transition_to!(new_status)` — validates transition, sets status + timestamp, saves
- `shipped` transition requires `tracking_number` to be present
- Status timestamp fields: `paid_at`, `shipped_at`, `delivered_at`, `cancelled_at`

**Acceptance Criteria:**
- [ ] `order.transition_to!(:shipped)` raises error if `tracking_number` is blank
- [ ] Invalid transition (e.g., `pending → delivered`) raises `Order::InvalidTransition`
- [ ] Each valid transition sets the correct timestamp field
- [ ] Test: all valid transitions, all invalid transitions, shipped guard

---

### EPIC 6: Transactional Emails

#### TICKET-014: OrderMailer
**Goal:** Order confirmation and status update emails to customers.

**Tasks:**
- `app/mailers/application_mailer.rb` — `default from: "Birds Bouquets <hello@birdsbouquets.com>"`
- `app/mailers/order_mailer.rb`:
  - `order_confirmation(order)` — sent immediately after payment; includes order number, items, total, shipping address
  - `order_shipped(order)` — sent on shipped status; includes tracking number, estimated delivery
  - `order_delivered(order)` — optional, sent on delivered status
- HTML templates + text fallbacks for each action
- `email_log_observer.rb` — mirrors ThetaPal: logs all sent emails to `email_logs` table
- Configure `letter_opener` in development

**Acceptance Criteria:**
- [ ] `OrderMailer.order_confirmation(order).deliver_later` enqueues on mailers queue
- [ ] Confirmation email includes order number, all items, total
- [ ] Shipped email includes tracking number
- [ ] All sent emails appear in `email_logs` table
- [ ] In development, emails open in browser via letter_opener
- [ ] Test: `test/mailers/order_mailer_test.rb` — subject, recipient, key body content for each action

---

#### TICKET-015: AdminMailer & Notification Jobs
**Goal:** Admin notifications and background email dispatch.

**Tasks:**
- `app/mailers/admin_mailer.rb`:
  - `new_order(order)` — sent to admin on each new paid order (include order number, total, customer email)
  - `new_signup(user)` — sent to admin on new user registration
- `app/jobs/send_order_notification_job.rb` — queued by `StripeWebhooksController` on `payment_intent.succeeded`; sends `OrderMailer.order_confirmation` + `AdminMailer.new_order`
- `app/jobs/daily_order_digest_job.rb` — cron 8 AM CT daily; sends admin a summary of yesterday's orders: count, revenue, new customers
- Add both jobs to GoodJob cron in `config/initializers/good_job.rb`

**Acceptance Criteria:**
- [ ] New paid order triggers both customer confirmation and admin notification within 60 seconds
- [ ] Daily digest email shows correct counts and revenue for previous day
- [ ] Jobs appear in GoodJob queue dashboard at `/good_job`
- [ ] Test: `SendOrderNotificationJob.perform_later(order.id)` enqueues both mailer calls

---

### EPIC 7: Admin Dashboard

#### TICKET-016: Admin Core & Layout
**Goal:** Secure admin area with dashboard metrics.

**Tasks:**
- `app/controllers/admin/base_controller.rb` — `before_action :require_admin!`; `require_admin!` checks `current_user&.admin?`, redirects to root with flash if not
- `app/views/layouts/admin.html.erb` — sidebar layout: Dashboard, Products, Categories, Orders, Customers, Blog
- `admin/dashboard_controller.rb#index`:
  - Today's order count and revenue
  - Pending/processing orders count (needing action)
  - Out-of-stock products count
  - New customers this week
  - Last 7 days revenue chart data
- Mount GoodJob UI at `/admin/good_job` (for job monitoring)

**Acceptance Criteria:**
- [ ] `GET /admin` by non-admin user redirects to root with "Access denied" flash
- [ ] Admin layout renders sidebar with all nav links
- [ ] Dashboard shows today's order count and total revenue (correct values)
- [ ] Test: `test/controllers/admin/dashboard_controller_test.rb` — non-admin redirect, admin access

---

#### TICKET-017: Admin Product Management
**Goal:** Full product CRUD including image management.

**Tasks:**
- `admin/products_controller.rb` — index, new, create, edit, update, destroy, toggle_in_stock, toggle_featured
- Product form: all fields including SEO fields, category dropdown, price input (displays in dollars, saves as cents)
- Image management section: upload multiple images, reorder by position (simple position number inputs), remove individual images
- Guard on destroy: if product has any `OrderItem` records, show error and do not delete (or soft-delete with `discarded_at`)
- Filter/search: search by name, filter by category, filter by in_stock status

**Acceptance Criteria:**
- [ ] Admin can create product with name, description, price, category, images
- [ ] Price field shows `"24.99"` for `price_cents: 2499`, saves correctly on update
- [ ] Toggle in-stock flips `in_stock` boolean and reloads page with success flash
- [ ] Cannot destroy product with existing orders (flash error shown)
- [ ] Image upload creates `ProductImage` record with correct position
- [ ] Test: price cents conversion, image creation, destroy guard

---

#### TICKET-018: Admin Category Management
**Goal:** Category CRUD with product count and guard on delete.

**Tasks:**
- `admin/categories_controller.rb` — index, new, create, edit, update, destroy
- Category index shows product count per category
- Guard: cannot destroy category that has products (show error)
- Position reordering via simple position inputs on index
- SEO fields in form (meta_description)

**Acceptance Criteria:**
- [ ] Admin can create, edit, delete categories
- [ ] Delete of category with products shows "Cannot delete: X products in this category"
- [ ] Slug is auto-generated from name on create (editable on edit)
- [ ] Test: CRUD actions, delete guard, slug generation

---

#### TICKET-019: Admin Order Management
**Goal:** Admin can view, filter, and update all orders.

**Tasks:**
- `admin/orders_controller.rb` — index, show, update_status, add_tracking
- Order index with filters: status dropdown, date range pickers, search by email or order number
- Order detail: all customer info, items + prices, current status, status history (implicit via timestamps)
- Status update form: dropdown of valid next statuses + tracking number input (shown when shipping)
- On status update: call `order.transition_to!(new_status)`, then enqueue customer notification email
- CSV export: `GET /admin/orders.csv` with date range params

**Acceptance Criteria:**
- [ ] Admin can update order from `paid` to `processing`
- [ ] Updating to `shipped` requires tracking number (form validation)
- [ ] Status update to `shipped` triggers `OrderMailer.order_shipped` to customer
- [ ] Date-range filter returns correct orders
- [ ] CSV download includes order_number, email, total, status, date
- [ ] Test: status update triggers mailer, tracking number guard

---

#### TICKET-020: Admin Customer Management
**Goal:** Admin can browse customers and view their history.

**Tasks:**
- `admin/customers_controller.rb` — index, show
- Customer index: searchable by email/name, sortable by join date and total spend
- Customer detail: profile info (name, email, phone), all orders with status and total, lifetime value, addresses on file
- Admin can add `admin_notes` to individual orders from customer detail view

**Acceptance Criteria:**
- [ ] Search by partial email returns matching customers
- [ ] Customer detail shows correct lifetime value (sum of paid order totals)
- [ ] Sorting by total spend orders correctly
- [ ] Test: email search, lifetime value calculation

---

### EPIC 8: SEO & GEO Infrastructure

#### TICKET-021: SEO Helper & Structured Data
**Goal:** Comprehensive SEO helper mirroring ThetaPal's `seo_helper.rb` pattern.

**Tasks:**
- `app/helpers/seo_helper.rb`:
  - `seo_meta(title:, description:, url:, image: nil, keywords: nil)` — sets `@seo_*` instance vars, rendered in `_seo_head.html.erb`
  - `organization_structured_data()` — Organization JSON-LD with name, URL, contact
  - `local_business_structured_data()` — LocalBusiness JSON-LD (key for GEO — city-specific flower searches)
  - `product_structured_data(product)` — schema.org/Product with name, description, image, price, availability
  - `faq_structured_data(faqs)` — FAQPage JSON-LD (array of `{question:, answer:}` hashes)
  - `breadcrumb_structured_data(items)` — BreadcrumbList JSON-LD
  - `article_structured_data(post)` — Article JSON-LD for blog posts
- `app/views/layouts/_seo_head.html.erb` — meta tags, OG tags, Twitter cards, canonical, structured data yield
- Add SEO meta to every controller action

**Acceptance Criteria:**
- [ ] Product show page source contains valid `application/ld+json` with `@type: "Product"` and correct price
- [ ] Homepage source contains Organization JSON-LD
- [ ] Meta description is unique on every public page
- [ ] `seo_helper_test.rb` unit tests for each structured data method (valid JSON-LD output)

---

#### TICKET-022: Sitemap Generation
**Goal:** XML sitemap covering all indexable public URLs.

**Tasks:**
- Configure `config/sitemap.rb`:
  - Static URLs: `/`, `/products`, `/about`, `/faq`, `/contact`, `/blog`, `/orders/lookup`
  - Dynamic: `Product.in_stock.each` → `/products/:slug`
  - Dynamic: `Category.active.each` → `/products?category=:slug`
  - Dynamic: `BlogPost.published.each` → `/blog/:slug`
- `SitemapRefreshJob` — calls `SitemapGenerator::Sitemap.create` — scheduled weekly Sunday 2 AM
- Add `Sitemap: https://birdsbouquets.com/sitemap.xml` to robots.txt

**Acceptance Criteria:**
- [ ] `rails sitemap:refresh` generates valid XML at `public/sitemap.xml`
- [ ] All in-stock products appear in sitemap
- [ ] Sitemap URL is referenced in robots.txt
- [ ] `SitemapRefreshJob.perform_later` runs without error

---

#### TICKET-023: GEO & llms.txt
**Goal:** Optimize for AI-powered search engines (Perplexity, ChatGPT, Claude, Gemini).

**Tasks:**
- Create `public/llms.txt`:
  - Service name and description
  - What we sell (flower types, categories)
  - Service area and delivery info
  - Ordering process (add to cart → checkout → email confirmation → delivery)
  - Return/refund policy summary
  - Contact information
- Create `public/llms-full.txt`:
  - Full product catalog with descriptions and prices
  - Complete FAQ text
  - Full policies
  - Company story
- Ensure all product image `alt_text` is non-empty (add DB validation: `validates :alt_text, presence: true`)
- Add `loading="lazy"` to all non-hero product images
- Add semantic H1/H2/H3 hierarchy to all public pages

**Acceptance Criteria:**
- [ ] `GET /llms.txt` returns 200 with plain text content
- [ ] `GET /llms-full.txt` returns 200 with comprehensive content
- [ ] `ProductImage` with blank `alt_text` fails validation
- [ ] Test: static file serving, ProductImage alt_text validation

---

### EPIC 9: Marketing & Public Pages

#### TICKET-024: Homepage & Landing
**Goal:** Compelling homepage that converts visitors and ranks for flower keywords.

**Tasks:**
- `PagesController#home` — root route, queries `Product.featured.in_stock.limit(6)` and `Category.active.ordered`
- Homepage sections:
  1. Hero: H1 keyword-rich headline, subheadline, "Shop Now" CTA button
  2. Featured Products: 6-up grid of `ProductCardComponent`
  3. Shop by Category: category tiles with images
  4. Value props: Fresh flowers, fast delivery, satisfaction guaranteed
  5. Trust signals: Simple testimonials section
- Organization + LocalBusiness JSON-LD on homepage
- Fully mobile-responsive layout

**Acceptance Criteria:**
- [ ] Homepage loads without errors and shows featured products
- [ ] H1 contains primary keyword
- [ ] Featured products section renders `ProductCardComponent` for each result
- [ ] Page is usable on 375px wide mobile
- [ ] Test: `PagesController#home` returns 200, assigns `@featured_products`

---

#### TICKET-025: Static Marketing Pages
**Goal:** Trust and SEO pages.

**Tasks:**
- `PagesController#faq` — FAQ with FAQPage JSON-LD (10+ questions about ordering, delivery, freshness, returns)
- `AboutController#index` — company story, values, "why flowers" messaging
- `ContactController#new` / `#create` — contact form that sends email to admin via `ContactMailer`
- `LegalController#privacy_policy`, `#terms_of_service`, `#return_policy`
- All pages use `landing.html.erb` layout with SEO meta
- Unique meta description on every page

**Acceptance Criteria:**
- [ ] All static pages return 200 without auth
- [ ] FAQ page source contains FAQPage JSON-LD with at least 5 Q&A pairs
- [ ] Contact form submits without error and sends admin email
- [ ] Legal pages are accessible and have unique meta titles
- [ ] Test: all static pages return 200, contact form sends email

---

#### TICKET-026: Blog
**Goal:** Content marketing blog for long-tail SEO.

**Tasks:**
- `BlogPost` model (from schema above) with `before_validation :generate_slug`
- `admin/blog_posts_controller.rb` — CRUD, publish/draft toggle
- `BlogController#index` — list of published posts (paginated, newest first)
- `BlogController#show` — individual post with Article JSON-LD
- Blog index SEO: `seo_meta` with blog-level title and description
- Initial seed: 2 draft blog posts ("How to Care for Fresh Cut Flowers", "Best Flowers for Every Occasion")

**Acceptance Criteria:**
- [ ] Draft posts do NOT appear on `/blog` (only `status: 'published'` posts)
- [ ] Admin can publish/unpublish posts via toggle action
- [ ] Individual post page has Article JSON-LD with correct author and datePublished
- [ ] Blog index is paginated (limit 12 per page)
- [ ] Test: `test/controllers/blog_controller_test.rb` — draft hidden, published shown

---

### EPIC 10: Testing Suite

#### TICKET-027: Test Suite Foundation
**Goal:** Minitest foundation with fixtures and auth helpers.

**Tasks:**
- Configure `test/test_helper.rb`:
  - `Devise::Test::ControllerHelpers` included
  - `sign_in(user)` helper
  - OmniAuth test mode enabled
- Create fixtures for all core models in `test/fixtures/`:
  - `users.yml` — regular user, admin user, guest context
  - `categories.yml` — 2-3 categories
  - `products.yml` — 3-4 products across categories
  - `orders.yml` — one pending, one paid, one shipped order
  - `order_items.yml` — items for each order
  - `addresses.yml` — one default address for user
- System test setup with Capybara headless Chrome

**Acceptance Criteria:**
- [ ] `rails test` runs all tests on clean database (no errors on setup)
- [ ] `rails test:system` runs headless
- [ ] `sign_in(users(:admin))` works in controller tests
- [ ] All fixtures are valid and reference each other correctly

---

#### TICKET-028: Core Model Tests
**Goal:** Full unit test coverage for all critical models.

**Tasks:**
- `test/models/user_test.rb` — email/name/phone validations, `admin?`, `from_omniauth` upsert
- `test/models/product_test.rb` — validations, slug generation, `price_in_dollars`, `on_sale?`, scopes (in_stock, featured, by_category)
- `test/models/order_test.rb` — state machine transitions, `generate_order_number` uniqueness, `total_cents` calculation
- `test/models/order_item_test.rb` — price snapshot, quantity > 0 validation
- `test/models/address_test.rb` — required field validations, default uniqueness per user
- `test/models/category_test.rb` — validations, slug, `active` scope

**Acceptance Criteria:**
- [ ] All model tests pass with `rails test test/models/`
- [ ] State machine tests cover all valid and at least 3 invalid transitions
- [ ] Price helper tests confirm correct formatting
- [ ] No test uses `.reload` more than necessary (avoid N+1 in tests too)

---

#### TICKET-029: Controller & Mailer Tests
**Goal:** Integration test coverage for key public and admin flows.

**Tasks:**
- `test/controllers/products_controller_test.rb` — index accessible without auth, category filter, show page
- `test/controllers/orders_controller_test.rb` — index requires auth, show own order, show other user's order redirects, guest lookup
- `test/controllers/stripe_webhooks_controller_test.rb` — valid webhook updates order, invalid signature returns 400
- `test/controllers/admin/products_controller_test.rb` — auth guard, create, update price, destroy guard
- `test/controllers/admin/orders_controller_test.rb` — status update, tracking number guard
- `test/mailers/order_mailer_test.rb` — confirms subject, recipient, order number in body for each action
- `test/mailers/admin_mailer_test.rb` — new_order email contains order total

**Acceptance Criteria:**
- [ ] `rails test test/controllers/ test/mailers/` all pass
- [ ] Non-admin access to `/admin/*` returns redirect in all tests
- [ ] Guest order lookup test: correct credentials returns order, wrong returns nothing
- [ ] Mailer tests verify both subject line and at least one body content assertion

---

### EPIC 11: Deployment

#### TICKET-030: Docker & Render Deployment
**Goal:** Production-ready deployment on Render.com.

**Tasks:**
- Finalize `Dockerfile` (multi-stage: builder stage with dev gems, production stage without them; run as non-root user)
- `render.yaml`:
  - Web service: Docker runtime, port 3000, env vars from Render dashboard
  - Worker service: `bundle exec good_job start`, same env vars
  - PostgreSQL: managed database
- `config/environments/production.rb`: force SSL, configure Active Storage, configure SMTP
- Active Storage production config: Cloudflare R2 (or AWS S3 compatible)
- Health check endpoint: `GET /health` → `render_text 'ok'`
- `db/seeds.rb`: create admin user from `ENV['ADMIN_EMAIL']` and `ENV['ADMIN_PASSWORD']`, seed initial categories
- `.env.example` with all required vars documented

**Required ENV Vars:**
```
RAILS_MASTER_KEY
DATABASE_URL
STRIPE_SECRET_KEY
STRIPE_PUBLISHABLE_KEY
STRIPE_WEBHOOK_SECRET
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET
SMTP_ADDRESS
SMTP_PORT
SMTP_USERNAME
SMTP_PASSWORD
ADMIN_EMAIL
CLOUDFLARE_R2_BUCKET
CLOUDFLARE_R2_ACCESS_KEY_ID
CLOUDFLARE_R2_SECRET_ACCESS_KEY
CLOUDFLARE_R2_ENDPOINT
```

**Acceptance Criteria:**
- [ ] `docker build -t birds_bouquets .` completes successfully
- [ ] `GET /health` returns `200 ok` (used by Render health checks)
- [ ] `rails db:seed` creates admin user and initial categories
- [ ] `render.yaml` passes render validate (or deploys clean first time)
- [ ] All env vars documented in `.env.example`

---

## 8. Ticket Build Order Summary

| # | Ticket | Epic | Size |
|---|--------|------|------|
| 1 | Rails App Bootstrap | Foundation | M |
| 2 | GoodJob Configuration | Foundation | S |
| 3 | User Model & Devise | Auth | M |
| 4 | User Address Management | Auth | S |
| 5 | Category Model | Catalog | S |
| 6 | Product Model | Catalog | S |
| 7 | Product Images (Active Storage) | Catalog | S |
| 8 | Public Product Catalog | Catalog | M |
| 9 | Shopping Cart (Session) | Cart | M |
| 10 | Checkout Flow | Cart | L |
| 11 | Stripe Payment Integration | Cart | M |
| 12 | Order Tracking (Customer) | Orders | M |
| 13 | Order Status State Machine | Orders | S |
| 14 | OrderMailer | Email | S |
| 15 | AdminMailer & Jobs | Email | S |
| 16 | Admin Core & Layout | Admin | S |
| 17 | Admin Product Management | Admin | M |
| 18 | Admin Category Management | Admin | S |
| 19 | Admin Order Management | Admin | M |
| 20 | Admin Customer Management | Admin | S |
| 21 | SEO Helper & Structured Data | SEO | M |
| 22 | Sitemap Generation | SEO | S |
| 23 | GEO & llms.txt | SEO | S |
| 24 | Homepage & Landing | Marketing | M |
| 25 | Static Marketing Pages | Marketing | S |
| 26 | Blog | Marketing | M |
| 27 | Test Suite Foundation | Testing | S |
| 28 | Core Model Tests | Testing | M |
| 29 | Controller & Mailer Tests | Testing | M |
| 30 | Docker & Render Deployment | Deployment | M |

**Build order rationale:** Each epic builds on the previous. Foundation → Auth (users exist) → Catalog (products exist) → Cart & Checkout (can shop) → Orders (can track) → Email (confirmations) → Admin (can manage) → SEO (indexable) → Marketing (discoverable) → Testing (verified) → Deploy (live).

---

## 9. Key Architectural Decisions (Mirroring ThetaPal)

1. **GoodJob over Sidekiq** — No Redis dependency; PostgreSQL-backed jobs integrate cleanly with existing DB; same pattern as ThetaPal
2. **Session-based cart** — No cart model needed; CartService encapsulates all logic; works for guests and logged-in users identically
3. **Denormalized order snapshot** — `order_items.unit_price_cents` and `order_items.product_name` are snapshots at order time; historical accuracy preserved even if product is edited or deleted later
4. **InputSanitizable concern on all models** — Mirror ThetaPal's pattern; strips null bytes and control characters before validation
5. **No pagination gem** — Use Rails built-in `limit/offset` or Kaminari if needed; keep dependencies minimal
6. **ViewComponent for reusable UI** — `ProductCardComponent`, `OrderStatusTimelineComponent` follow ThetaPal's component pattern
7. **Service object for cart** — `CartService` in `app/services/` keeps controller thin; mirrors ThetaPal's 145+ service object pattern
8. **Landing layout separate from app layout** — Public pages use `landing.html.erb` (full SEO head, no auth nav); authenticated pages use `application.html.erb`; admin uses `admin.html.erb`

---

*This plan is the master epic. Each ticket is sized to be completable and fully testable in a single Claude session. Build in sequence; validate acceptance criteria before moving to the next ticket.*
