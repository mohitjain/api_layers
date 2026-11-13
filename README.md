# api_layers

Build JSON APIs as small, separate, testable pieces instead of fat controllers.

Inspired by use-case-driven and layered architecture: the business logic is the core of the product, so it should not
depend on the framework. A controller (or a Sidekiq job) only collects the input and hands it to the core.

> **Status: under development.** Version 0.1.0, not on RubyGems; install it from GitHub. It was written for a Rails
> app and expects Rails, ActiveRecord and a logger. It uses `Module#parents` (removed in Rails 6.1) and reports
> unexpected errors to Sentry through the old `Raven` client, so it needs work before it runs on current Rails.

## The pieces

Each API call is made of parts that know nothing about each other and meet through small interfaces:

| Part | Job |
|---|---|
| **Request** | Everything the service needs as input: `params`, `current_user`, and anything else you add. |
| **Service** | Does the one unit of work. Input and output pass through it and no logic leaks outside. |
| **Validators** | Preconditions the service checks before it does the work. |
| **Result data** | What the service returns. |
| **Presenter** | Turns the result data into the shape the API returns. |
| **Response** | Decides success or failure and the HTTP status, and builds the response hash. |

[`ServiceCommandExecutor`](lib/api_layers/service_command_executor.rb) runs them in order: it creates the service,
executes it, presents the data and builds the response. Validation errors (including ActiveRecord's) become a
`400 Bad Request` response; any other error becomes a `500` with a generic message.

## Install

```ruby
gem 'api_layers', git: 'https://github.com/mohitjain/api_layers.git'
```

## Use

Build the request object once per request, in your `ApplicationController`:

```ruby
before_action :set_api_request_object

attr_accessor :api_request_object

def set_api_request_object
  self.api_request_object = ApiLayers::Request.new(
    params: params,
    current_user: (current_user || @user),
    access: @access,
    app: @app
  )
end
```

Then run a service from a controller action and render what comes back:

```ruby
class BookingsController < ApplicationController
  def index
    response = ApiLayers::ServiceCommandExecutor.new(
      service_class: Services::BookingServices::Index,
      request: api_request_object,
      response_class: ApiLayers::Responses::Base,
      data_presenter_class: Presenters::BookingPresenters::ShowPresenter
    ).execute

    render(response.to_hash)
  end

  def create
    response = ApiLayers::ServiceCommandExecutor.new(
      service_class: Services::BookingServices::Create,
      request: api_request_object,
      response_class: ApiLayers::Responses::Create,
      data_presenter_class: Presenters::BookingPresenters::ShowPresenter
    ).execute

    render(response.to_hash)
  end
end
```

Your services inherit from `ApiLayers::Services::Base` and implement `execute!` and `validation_error_classes`.
`ApiLayers::Responses::Base` covers simple GETs; `Create`, `Update` and `UnprocessableEntity` are ready-made for
writes. Generic services, presenters, validators and action configurations for collections and single records live
under `lib/api_layers/`.

Because each part runs on its own, each gets its own fast unit tests with no controller in the way.

## Development

```
bin/setup
bundle exec rspec
bin/console
```

## Contributing

Bug reports and pull requests are welcome at https://github.com/mohitjain/api_layers.
