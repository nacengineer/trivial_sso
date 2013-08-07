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

describe TrivialSso do
  let(:sso_secret) {SecureRandom.hex(64)}
  let(:userdata) {
    {
      'username' => Forgery::Internet.user_name,
      'groups'   => ['one', 'two']
    }
  }
  let(:trivial_sso) {TrivialSso::Login.new}
  # let(:expired_cookie) {
  #   TrivialSso::Login.cookie({'username' => 'testor'}, 2.seconds.ago)
  # }

  it "does set the data" do
    trivial_sso.data = userdata

    trivial_sso.data.should          be_kind_of OpenStruct
    trivial_sso.data.username.should eq userdata['username']
    trivial_sso.data.groups.should   eq userdata['groups']
  end

  it "does create cookie with userdata" do
    trivial_sso.data = userdata
    trivial_sso.wrap.should be_kind_of String
  end

  it "should encode and decode" do
    trivial_sso.data = userdata
    cookie           = trivial_sso.wrap
    trivial_sso.cookie = cookie

    trivial_sso.unwrap.should eq userdata
  end

  # def test_throw_exception_on_missing_username
  #   assert_raise TrivialSso::Error::NoUsernameCookie do
  #     mycookie = TrivialSso::Login.cookie("")
  #   end
  # end

  # def test_expire_date_exists
  #   # in a full rails environment, this will return an ActiveSupport::TimeWithZone
  #   assert TrivialSso::Login.expire_date.is_a?(Time),
  #     "proper Time object not returned"
  # end

  # def test_expire_date_is_in_future
  #   assert (DateTime.now < TrivialSso::Login.expire_date),
  #     "Expire date is in the past - cookie will expire immediatly."
  # end

  # def test_raise_exception_on_blank_cookie
  #   assert_raise TrivialSso::Error::MissingCookie do
  #     TrivialSso::Login.decode_cookie("")
  #   end
  # end

  # def test_raise_exception_on_bad_cookie
  #   assert_raise TrivialSso::Error::BadCookie do
  #     TrivialSso::Login.decode_cookie("BAhbB0kiC2RqbGVlMgY6BkVUbCsHo17iTg")
  #   end
  # end

  # def test_raise_exception_on_expired_cookie
  #   assert_raise TrivialSso::Error::LoginExpired do
  #     TrivialSso::Login.decode_cookie(@expired_cookie)
  #   end
  # end

end
