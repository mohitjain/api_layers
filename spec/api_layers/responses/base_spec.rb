describe ApiLayers::Responses::Base do

  let(:test_error_message) { 'test error message' }
  let(:test_error) { StandardError.new(test_error_message) }
  let(:test_data) do
    {
      test: true
    }
  end

  context '#initialize' do
    subject do
      ApiLayers::Responses::Base.new(
        data: test_data,
        error: test_error,
        error_message: test_error_message,
      )
    end

    it 'sets data with the given data' do
      expect(subject.data).to be(test_data)
    end

    it 'sets error with the given error object' do
      expect(subject.error).to be(test_error)
    end

    it 'sets error_message with the given error_message' do
      expect(subject.error_message).to be(test_error_message)
    end
  end

  context '#to_hash' do
    context 'when data is present, and error and error_message are blank' do
      subject do
        ApiLayers::Responses::Base.new(
          data: test_data
        )
      end

      let(:test_success_response_hash) do
        {
          json: {
            success: true,
          }.merge(test_data),
          status: :ok
        }
      end

      it 'returns success response hash' do
        expect(subject.to_hash).to eq(test_success_response_hash)
      end
    end

    context 'when an unexpected error is given' do
      subject do
        ApiLayers::Responses::Base.new(
          error: test_error
        )
      end

      let(:test_error_response_hash) do
        {
          json: {
            success: false,
            error: {
              type: 'error',
              message: 'Something went wrong'
            }
          },
          status: :internal_server_error
        }
      end

      it 'returns unexpected error(500) response hash' do
        expect(subject.to_hash).to eq(test_error_response_hash)
      end
    end

    context 'when an expected error is given' do
      subject do
        ApiLayers::Responses::Base.new(
          error_message: test_error_message
        )
      end

      let(:test_bad_request_response_hash) do
        {
          json: {
            success: false,
            error: {
              type: 'error',
              message: test_error_message
            }
          },
          status: :bad_request
        }
      end

      it 'returns expected error(400) response hash' do
        expect(subject.to_hash).to eq(test_bad_request_response_hash)
      end
    end

    context 'when an ActiveRecord validation error is given' do
      let(:test_record) do
        test_record = TestRecord.new
        allow(test_record).to receive(:errors).and_return(ActiveModel::Errors.new(test_record))
        test_record.errors.add(:test_attr, test_error_message)
        test_record
      end

      let(:activerecord_validation_error) do
        ActiveRecord::RecordInvalid.new(test_record)
      end

      subject do
        ApiLayers::Responses::Base.new(
          error: activerecord_validation_error,
          error_message: test_error_message,
          unexpected_error: false
        )
      end

      let(:test_validation_error_response_hash) do
        {
          json: {
            success: false,
            error: {
              type: 'error',
              message: test_error_message
            },
            errors: activerecord_validation_error.record.errors,
            full_error_messages: activerecord_validation_error.record.errors.full_messages
          },
          status: :bad_request
        }
      end

      it 'returns expected error response(500) hash with all errors' do
        expect(subject.to_hash).to eq(test_validation_error_response_hash)
      end
    end
  end

  context '#success?' do
    context 'when data is present, and error and error_message are blank' do
      subject do
        ApiLayers::Responses::Base.new(
          data: test_data
        )
      end

      it 'returns true' do
        expect(subject.success?).to be(true)
      end
    end

    context 'when data given is blank' do
      subject do
        ApiLayers::Responses::Base.new(
          data: {}
        )
      end

      it 'returns false' do
        expect(subject.success?).to be(false)
      end
    end

    context 'when error is given' do
      subject do
        ApiLayers::Responses::Base.new(
          error: test_error
        )
      end

      it 'returns false' do
        expect(subject.success?).to be(false)
      end
    end

    context 'when error_message is given' do
      subject do
        ApiLayers::Responses::Base.new(
          error_message: test_error_message
        )
      end

      it 'returns false' do
        expect(subject.success?).to be(false)
      end
    end
  end

  context 'ACTIVE_RECORD_VALIDATION_ERRORS' do
    it 'is correct' do
      expect(described_class::ACTIVE_RECORD_VALIDATION_ERRORS)
        .to(
          eq(
            [
              ActiveRecord::RecordInvalid,
              ActiveRecord::RecordNotSaved
            ]
          )
        )
    end
  end

  context '#success_status' do
    it 'returns :ok' do
      expect(subject.success_status).to be(:ok)
    end
  end

  [:data=, :error=, :error_message=].each do |attribute|
    context "\##{attribute}" do
      it 'is a protected method' do
        expect(attribute).to be_protected
      end
    end
  end
end
