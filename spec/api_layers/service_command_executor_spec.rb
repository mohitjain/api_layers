describe ApiLayers::ServiceCommandExecutor do

  let(:params_hash) do
    {
      test: true
    }
  end

  let(:test_error_message) { 'test error message' }
  let(:test_activerecord_validation_error_message) { 'test validation error' }
  let(:test_validation_error_class) do
    Class.new(StandardError)
  end
  let(:test_validation_error) { test_validation_error_class.new(test_error_message) }
  let(:test_active_record_error) do
    record = TestRecord.new
    errors = ActiveModel::Errors.new(record)
    errors.add(:test_attr, test_activerecord_validation_error_message)
    allow(record).to receive(:errors).and_return(errors)
    ActiveRecord::RecordInvalid.new(record)
  end
  let(:test_error) { StandardError.new(test_error_message) }

  let(:test_service_class) { double('ApiLayers::Services::TestClass') }
  let(:test_service_object) { double('ApiLayers::Services::TestObject') }

  let(:test_data_presenter_class) { double('ApiLayers::Presenters::TestClass') }
  let(:test_data_presenter_object) { double('ApiLayers::Presenters::TestObject') }

  let(:test_response_class) { double('ApiLayers::Responses::TestClass') }
  let(:test_response_object) { double('ApiLayers::Responses::TestObject') }
  let(:test_validation_error_response_object) do
    double('ApiLayers::Responses::TestValidationErrorObject')
  end
  let(:test_active_record_error_response_object) do
    double('ApiLayers::Responses::TestARValidationErrorObject')
  end
  let(:test_error_response_object) { double('ApiLayers::Responses::TestErrorObject') }

  let(:test_request) { double('ApiLayers::Request') }

  let(:test_service_result_data) do
    {
      result: 'success'
    }
  end

  let(:rails_logger) do
    double('Rails.logger')
  end

  before do
    allow(test_request).to receive(:params).and_return(params_hash)
    allow(test_request).to receive(:current_user).and_return(nil)

    allow(test_service_class)
      .to(
        receive(:new)
          .with(test_request)
          .and_return(test_service_object)
      )

    allow(test_service_class)
      .to receive(:parents).and_return([])

    allow(test_data_presenter_class)
      .to(
        receive(:new)
          .with(data: test_service_result_data, request: test_request)
          .and_return(test_data_presenter_object)
      )

    allow(test_data_presenter_class)
      .to receive(:parents).and_return([])

    allow(test_response_class)
      .to(
        receive(:new)
          .with(data: test_service_result_data)
          .and_return(test_response_object)
      )

    allow(test_response_class)
      .to(
        receive(:new)
          .with(
            error: test_validation_error, error_message: test_error_message,
            data: nil, unexpected_error: false
          )
          .and_return(test_validation_error_response_object)
      )

    allow(test_response_class)
      .to(
        receive(:new)
          .with(
            error: test_active_record_error,
            error_message: test_active_record_error.record.errors.full_messages.first,
            data: nil, unexpected_error: false
          )
          .and_return(test_active_record_error_response_object)
      )

    allow(test_response_class)
      .to(
        receive(:new)
          .with(error: test_error, error_message: nil, data: nil, unexpected_error: true)
          .and_return(test_error_response_object)
      )

    allow(test_service_object)
      .to(
        receive(:validation_error_classes)
          .and_return([test_validation_error_class])
      )

    allow(test_validation_error).to receive(:message).and_return(test_error_message)
    allow(test_error).to receive(:message).and_return(test_error_message)

    allow(Rails).to receive(:logger).and_return(rails_logger)
    allow(rails_logger).to receive(:info)
    allow(rails_logger).to receive(:error)
  end

  context '#initialize' do
    subject do
      ApiLayers::ServiceCommandExecutor.new(
        service_class: test_service_class,
        request: test_request,
        response_class: test_response_class,
        data_presenter_class: test_data_presenter_class
      )
    end

    it 'sets service_object with a new instance of service_class' do
      expect(subject.service_object).to eq(test_service_object)
    end
  end

  context '#execute' do
    subject do
      ApiLayers::ServiceCommandExecutor.new(
        service_class: test_service_class,
        request: test_request,
        response_class: test_response_class,
        data_presenter_class: test_data_presenter_class
      )
    end

    context 'when service executes successfully' do
      before do
        allow(test_service_object).to receive(:execute!).and_return(test_service_result_data)
        allow(test_data_presenter_class).to receive(:is_a?).with(Class).and_return(true)
        allow(test_data_presenter_object).to(
          receive(:data_hash).and_return(test_service_result_data)
        )
      end

      it 'creates a new response object with the result data' do
        expect(test_response_class).to receive(:new).with(data: test_service_result_data)
        subject.execute
      end

      it 'returns the success response object' do
        response = subject.execute
        expect(response).to be(test_response_object)
      end
    end

    context 'when service raises validation error' do
      subject do
        ApiLayers::ServiceCommandExecutor.new(
          service_class: test_service_class,
          request: test_request,
          response_class: test_response_class,
          data_presenter_class: test_data_presenter_class
        )
      end

      before do
        allow(test_service_object).to receive(:execute!).and_raise(test_validation_error)
      end

      it 'logs error to Rails logs' do
        expect(rails_logger).to(
          receive(:error)
            .with(
              "[#{described_class.name}] #{test_validation_error.class.name}: " + test_error_message
            )
        )
        subject.execute
      end

      it 'returns error response' do
        expect(test_response_class).to receive(:new).with(error: test_validation_error,
                                                          error_message: test_error_message,
                                                          data: nil,
                                                          unexpected_error: false)

        response = subject.execute
        expect(response).to be(test_validation_error_response_object)
      end
    end

    context 'when service raises ActiveRecord validation error' do
      subject do
        ApiLayers::ServiceCommandExecutor.new(
          service_class: test_service_class,
          request: test_request,
          response_class: test_response_class,
          data_presenter_class: test_data_presenter_class
        )
      end

      before do
        allow(test_service_object).to(
          receive(:execute!).and_raise(
            test_active_record_error
          )
        )
      end

      it 'logs error to Rails logs' do
        expect(rails_logger).to(
          receive(:error)
            .with(
              "[#{described_class.name}] #{test_active_record_error.class.name}: "\
              "#{test_active_record_error.message}"
            )
        )
        subject.execute
      end

      it 'returns validation error response' do
        expect(test_response_class).to(
          receive(:new).with(
            error: test_active_record_error,
            error_message: test_active_record_error.record.errors.full_messages.first,
            data: nil,
            unexpected_error: false
          )
        )

        response = subject.execute
        expect(response).to be(test_active_record_error_response_object)
      end
    end

    context 'when service raises unexpected error' do
      subject do
        ApiLayers::ServiceCommandExecutor.new(
          service_class: test_service_class,
          request: test_request,
          response_class: test_response_class,
          data_presenter_class: test_data_presenter_class
        )
      end

      before do
        allow(test_service_object).to receive(:execute!).and_raise(test_error)
      end

      it 'logs error to Rails logs' do
        expect(rails_logger).to(
          receive(:error)
            .with(
              "[#{described_class.name}] #{test_error.class.name}: " + test_error.message
            )
        )
        subject.execute
      end

      it 'logs error to sentry' do
        expect(Raven).to receive(:capture_exception).with(test_error, level: 'warning')
        subject.execute
      end

      it 'returns error response' do
        expect(test_response_class).to receive(:new).with(error: test_error,
                                                          error_message: nil,
                                                          data: nil,
                                                          unexpected_error: true)
        response = subject.execute
        expect(response).to be(test_error_response_object)
      end
    end
  end

  context '#data_presenter_class' do
    context 'when data_presenter_class is a Class' do
      before do
        allow(test_data_presenter_class).to receive(:is_a?).with(Class).and_return(true)
      end

      subject do
        ApiLayers::ServiceCommandExecutor.new(
          service_class: test_service_class,
          request: test_request,
          response_class: test_response_class,
          data_presenter_class: test_data_presenter_class
        )
      end

      it 'returns the data_presenter_class' do
        expect(subject.data_presenter_class).to be(test_data_presenter_class)
      end
    end

    context 'when data_presenter_class is not a Class' do
      subject do
        ApiLayers::ServiceCommandExecutor.new(
          service_class: test_service_class,
          request: test_request,
          response_class: test_response_class,
          data_presenter_class: nil
        )
      end

      it 'returns Presenters::NullPresenter' do
        expect(subject.data_presenter_class).to be(ApiLayers::Presenters::NullPresenter)
      end
    end
  end
end
