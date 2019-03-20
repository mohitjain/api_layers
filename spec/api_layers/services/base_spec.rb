describe ApiLayers::Services::Base do

  let(:params_hash) do
    {
      test: true
    }
  end

  let(:subject_derived_class) { Class.new(described_class) }

  let(:test_request) { ApiLayers::Request.new(params: params_hash) }

  let(:subject_derived_class_object) { subject_derived_class.new(test_request) }

  subject { described_class.new(test_request) }

  context '#initialize' do
    context 'when class being initialized is the Base class' do
      it 'raises ApiLayers::AbstractClassInitializationError' do
        expect { subject }
          .to raise_error(
                ApiLayers::AbstractClassInitializationError,
                "Cannot instantiate abstract class '#{described_class.name}'"
              )
      end
    end

    it 'sets request with the given api_request_object' do
      expect(subject_derived_class_object.request).to eq(test_request)
    end
  end

  context '#filter_params' do
    let(:params_with_filters) do
      {
        filters: {
          test1: 1,
          test2: 2
        }
      }
    end

    subject do
      subject_derived_class.new(ApiLayers::Request.new(params: params_with_filters))
    end

    it 'returns the filter params' do
      expect(subject.filter_params).to eq(params_with_filters[:filters])
    end
  end

  context '#validate_current_user!' do
    let(:subject_derived_class) do
      Class.new(described_class) do
        def execute!
          validate_current_user!
        end
      end
    end

    context 'when current user is missing' do
      subject do
        subject_derived_class.new(ApiLayers::Request.new(params: {}))
      end

      it 'raises LoggedInUserMissingError error' do
        expect { subject.execute! }.to(
          raise_error(
            described_class::LoggedInUserMissingError,
            'Current logged in user is missing'
          )
        )
      end
    end

    context 'when current user is present' do
      subject do
        subject_derived_class.new(
          ApiLayers::Request.new(
            params: {},
            current_user: double('TestUser')
          )
        )
      end

      it 'does not raise an error' do
        expect { subject.execute! }.to_not raise_error
      end
    end
  end

  context '#execute!' do
    it 'raises NotImplementedError' do
      expect { subject_derived_class_object.execute! }.to raise_error(NotImplementedError)
    end
  end

  context '#validation_error_classes' do
    it 'raises NotImplementedError' do
      expect { subject_derived_class_object.validation_error_classes }.to(
        raise_error(NotImplementedError)
      )
    end
  end

  [:request=].each do |attribute|
    context "\##{attribute}" do
      it 'is a protected method' do
        expect(attribute).to be_protected
      end
    end
  end
end
