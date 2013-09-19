require 'spec_helper'
require 'trivial_sso'
require 'forgery'

# mock out rails app for sso_secret
module TrivialSso
  class Application < Rails::Application
    config.sso_secret = SecureRandom.hex(64)
  end
end

describe TrivialSso::Api do
  let(:sso_secret)  {SecureRandom.hex(64)}
  let(:expire_time) {(Time.now - 1000).to_i}
  let(:userdata)    {
    {
      'username' => Forgery::Internet.user_name,
      'groups'   => ['one', 'two']
    }
  }


  it "gives cookie" do
    TrivialSso::Api.encode(userdata).should be_kind_of String
  end

  it "gives data" do
    data = TrivialSso::Api.decode(TrivialSso::Api.encode(userdata))
    data['username'].should eq userdata['username']
    data['groups'].should   eq userdata['groups']
  end

end

