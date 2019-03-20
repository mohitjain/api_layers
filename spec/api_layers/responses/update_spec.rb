describe ApiLayers::Responses::Update do
  context '#success_status' do
    it 'returns :ok' do
      expect(subject.success_status).to be(:ok)
    end
  end
end
