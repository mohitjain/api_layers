describe ApiLayers::Request do

  let(:test_params) do
    {
      test: true
    }
  end

  let(:test_user_profile) { double('TestUserProfile') }
  let(:test_current_user) { double('TestUser', user_profile: test_user_profile) }
  let(:test_app) { double('TestApiClient') }

  subject do
    described_class.new(
      params: test_params,
      current_user: test_current_user,
      app: test_app
    )
  end

  context '#initialize' do
    it 'sets params with the given params' do
      expect(subject.params).to be(test_params)
    end

    it 'sets current_user with the given current_user' do
      expect(subject.current_user).to be(test_current_user)
    end

    it 'sets error_message with the given error_message' do
      expect(subject.app).to be(test_app)
    end
  end
end
