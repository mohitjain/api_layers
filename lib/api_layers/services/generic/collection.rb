module ApiLayers
  module Services
    module Generic
      class Collection < Base

        DEFAULT_PER_PAGE = 20

        attr_accessor :config_object

        def initialize(request = nil, config_object = nil)
          self.config_object = config_object

          super(request)
        end

        def execute!
          validate_request!

          record_collection_data
        end

        def validation_error_classes
          []
        end

        private

        def validate_request!
          # generic presence validator
        end

        def per_page
          @per_page ||= params[:per_page] || DEFAULT_PER_PAGE
        end

        def page
          params[:page]
        end

        def records
          @records ||= (
            records = config_object.model_class.includes(includes_scope)
            if filter_params.present? and config_object.enable_filters
              records = records.apply_filters(filter_params)
            end
            records = records.page(page).per(per_page)
          )
        end

        def record_collection_data
          data = DataClasses::Generic::CollectionData.new

          data.data_collection = records.map do |record|
            DataClasses::Generic::RecordData.new(config_object, record)
          end

          data.pagination_hash = {
            current_page: records.current_page,
            total_pages: records.total_pages,
            total_count: records.total_count
          }

          data
        end

      end
    end
  end
end
