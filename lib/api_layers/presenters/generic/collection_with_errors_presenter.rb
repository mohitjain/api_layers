module ApiLayers
  module Presenters
    module Generic
      class CollectionWithErrorsPresenter < CollectionPresenter

        protected

        def collection_data_hash_array
          data.map do |data_item|
            data_hash = item_presenter_object(data_item).data_hash

            if data_item.record.errors.present?
              data_hash[:validation_errors] = errors_hash(data_item)
            end

            data_hash
          end
        end

        def errors_hash(data_item)
          return {} if data_item.record.errors.blank?

          {
            errors: data_item.record.errors,
            full_error_messages: data_item.record.errors.full_messages
          }
        end

        def set_bulk_action_status!(data_hash)
          return unless data.respond_to?(:bulk_action_success)

          data_hash[:bulk_action_success] = !!data.bulk_action_success
        end

      end
    end
  end
end
