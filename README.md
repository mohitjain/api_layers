# This is under development right now.

# ApiLayers

Model your JSON APIs as decoupled, reusable and testable components. This gem is inspired by Use Case Driven and Layered Architecture. Business logic must be decoupled from the framework because that is the core of our business(not the framework). Added benefit of fast test cases also included in this pack(free!).

Each API is composed of the following parts:
* **Service** - Executes the unit of work required from this API. No logic is exposed outside this class. Input and Output flow through it only.
* **Validator(s)** - One or more Validator classes define preconditions for the operation to be performed by the Service.
* **Request** - The request object(input) encapsulates all the information that is need by the Service to execute.
* **ResultData** - The result data(output) returned after the Service executes.
* **Presenter** - The presenter formats the data in the form required as the output of the API.
* **Response** - The Response class determines whether the operation was a success or failure and the final HTTP response to return.

Each component is independent of the other and they interact through clear interfaces. The [ServiceCommandExecutor](https://github.com/mohitjain/api_layers/blob/master/lib/api_layers/service_command_executor.rb) controls the interaction of all the components.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'api_layers', git: 'https://github.com/mohitjain/api_layers.git'
```

And then execute:

    $ bundle

~~Or install it yourself as:~~

~~$ gem install api_layers~~

## Usage

### Basic

The framework's execution Controller(Rails Controller, Sidekiq Job) should depend on the core and not the other way round. It should just be a dummy passing around work to the core.

Add the following function to your ApplicationController to create the Request object.

```
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

Trigger the service in your Controller.

```
class BookingsController

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

Write unit test cases for each component(run in isolation).

More details coming soon. The curious ones, read through the gem's code.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mohitjain/api_layers.
