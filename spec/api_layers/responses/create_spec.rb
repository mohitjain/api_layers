describe ApiLayers::Responses::Create do
  context '#success_status' do
    it 'returns :created' do
      expect(subject.success_status).to be(:created)
    end
  end
end
