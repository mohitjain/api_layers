require "api_layers/version"

require 'rails'
require 'active_record'
require 'active_record/validations'
require 'active_record/errors'
require 'active_support'
require 'active_support/hash_with_indifferent_access'

require 'sentry-raven'

require_relative 'api_layers/access_controlable'
require_relative 'api_layers/abstract_class_initialization_error'
require_relative 'api_layers/abstractable'

require_relative 'api_layers/errors/base'

require_relative 'api_layers/data_classes/base'
require_relative 'api_layers/data_classes/collectionable'
require_relative 'api_layers/data_classes/default'
require_relative 'api_layers/data_classes/default_collection'
require_relative 'api_layers/data_classes/generic/record_data'
require_relative 'api_layers/data_classes/generic/collection_data'

require_relative 'api_layers/presenters/core/exposed_attributes'
require_relative 'api_layers/presenters/base'
require_relative 'api_layers/presenters/collectionable'
require_relative 'api_layers/presenters/null_presenter'
require_relative 'api_layers/presenters/generic/show_presenter'
require_relative 'api_layers/presenters/generic/collection_presenter'
require_relative 'api_layers/presenters/generic/collection_with_errors_presenter'

require_relative 'api_layers/responses/base'
require_relative 'api_layers/responses/create'
require_relative 'api_layers/responses/update'
require_relative 'api_layers/responses/unprocessable_entity'

require_relative 'api_layers/services/base'
require_relative 'api_layers/services/generic/show'
require_relative 'api_layers/services/generic/collection'

require_relative 'api_layers/validators/base'
require_relative 'api_layers/validators/generic/record_presence_validator'

require_relative 'api_layers/service_command_executor'
require_relative 'api_layers/request'

require_relative 'api_layers/action_configurations/base'
require_relative 'api_layers/action_configurations/show'
require_relative 'api_layers/action_configurations/collection'

require_relative 'api_layers/generic_actions'
