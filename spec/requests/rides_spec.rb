describe "Rides API" do

  before :all do
    @user = Fabricate(:student)
    ApiKey.create!(user: @user)
    Fabricate.times(5, :ride, user: @user)
  end


  describe "GET /bulletins/rides.json" do
    it "returns all the rides" do
      #get '/bulletins/rides.json', format: :json
      #expect(response).to be_success
      #http_headers = { "Accept" => "application/json", "Authorization" => "Token token=\"#{@user.api_key.access_token}\"" }
      #get "/bulletins/rides.json", http_headers, {}
      #xhr :get, "/bulletins/rides"
      #expect(response.status).to eq 200
      #body = JSON.parse(response.body)
    end
  end

end
