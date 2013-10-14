require 'active_support/core_ext'
require 'trivial_sso'
require 'forgery'
require 'securerandom'

require 'rails'

# mock out rails app for sso_secret
module TrivialSso
  class Application < Rails::Application
    config.sso_secret = SecureRandom.hex(64)
  end
end

describe TrivialSso::Login do
  let(:sso_secret) {SecureRandom.hex(64)}
  let(:userdata) {
    {
      'username' => Forgery::Internet.user_name,
      'groups'   => ['one', 'two']
    }
  }

  let(:encode) {
    TrivialSso::Login.new({secret: sso_secret, data: userdata})
  }

  let(:decode) {
    TrivialSso::Login.new({secret: sso_secret, data: encode.wrap})
  }

  let(:expired_encode) {
    TrivialSso::Login.new(
      {data: userdata, secret: sso_secret, expire_time: (Time.now - 1000).to_i}
    )
  }

  it "does set the data" do
    encode.mode.should          eq :wrap
    encode.data.should          be_kind_of OpenStruct
    encode.data.username.should eq userdata['username']
    encode.data.groups.should   eq userdata['groups']
  end

  it "does create cookie with userdata" do
    encode.wrap.should be_kind_of String
  end

  it "should encode and decode" do
    decode.unwrap.should be_kind_of Hash
    decode.unwrap.should eq userdata
  end

  it "should encode and decode as OpenStruct" do
    decode.struct = true
    decode.unwrap.should be_kind_of OpenStruct
    decode.unwrap.should eq OpenStruct.new userdata
  end

  it "throw exception on missing username" do
    expect {
      encode.data = {username: ""}
      encode.wrap
    }.to raise_error TrivialSso::Error::NoUsernameData
  end

  it "throw exception on blank cookie" do
    expect {
      decode.data = ""
      decode.unwrap
    }.to raise_error TrivialSso::Error::BadData::Missing
  end

  it "raise exception bad signature when given cookie w/o signature as data source" do
    expect {
      decode.data = "BAhbB0kiC2RqbGVlMgY6BkVUbCsHo17iTg"
      decode.unwrap
    }.to raise_error TrivialSso::Error::BadData::Signature
  end

  it "raise exception bad message when given cookie w/o encryped data" do
    expect {
      decode.data = "--5b3164f6d1f09fb00d6905d073b18bc45a859b50"
      decode.unwrap
    }.to raise_error TrivialSso::Error::BadData::Signature
  end

  it "raise exception on expired cookie" do
    expect {
      decode.data         = expired_encode.wrap
      decode.unwrap
    }.to raise_error TrivialSso::Error::LoginExpired
  end

  it "raises if expire_time not valid" do
    expect {
      encode.expire_time = %w(this is bad data)
    }.to raise_error TrivialSso::Error::BadExpireTime
  end

  it "uses rails sso if Rails.defined" do
    encode.secret = Rails.configuration.sso_secret
    encode.sso_secret.should eq Rails.configuration.sso_secret
  end

end
