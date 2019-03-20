describe ApiLayers::Presenters::NullPresenter do
  context '#data_hash' do
    it 'returns blank hash' do
      expect(subject.data_hash).to eq({})
    end
  end
end
