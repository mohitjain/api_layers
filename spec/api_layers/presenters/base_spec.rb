describe ApiLayers::Presenters::Base do

  let(:data) do
    {
      test: true
    }
  end

  let(:subject_derived_class) do
    Class.new(described_class)
  end

  let(:subject_derived_class_object) { subject_derived_class.new(data: data) }

  subject { described_class.new(data: data) }

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

    it 'sets params with the given params_hash' do
      expect(subject_derived_class_object.data).to eq(data)
    end
  end

  context '#additional_field_present?' do
    let(:subject_derived_class) do
      Class.new(described_class) do
        def data_hash
          additional_field_present?('test_field1')
        end
      end
    end

    let(:api_request) do
      ApiLayers::Request.new(
        params: {
          additional_fields: 'test_field1,test_field2'
        }
      )
    end

    subject { subject_derived_class.new(data: nil, request: api_request) }

    it 'delegates to the request object' do
      expect(api_request).to receive(:additional_field_present?).with('test_field1')
      subject.data_hash
    end
  end

  [:data=, :request=, :root_node=].each do |attribute|
    context "\##{attribute}" do
      it 'is a protected method' do
        expect(attribute).to be_protected
      end
    end
  end
end
