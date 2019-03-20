describe ApiLayers::Responses::UnprocessableEntity do
  context '#success_status' do
    it 'returns :unprocessable_entity' do
      expect(subject.success_status).to be(:unprocessable_entity)
    end
  end
end
