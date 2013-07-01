module TrivialSso
  class Login

    # signing and un-signing may have to be refactored to use OpenSSL:HMAC...
    # as this will not work well across platforms. (ideally this should work for PHP as well)

    # Decodes and verifies an encrypted cookie
    # throw a proper exception if a bad or invalid cookie.
    # otherwise, return the username and userdata stored in the cookie
    def self.decode_cookie(cookie)
      begin
        raise TrivialSso::Error::MissingCookie if cookie.blank?
        userdata, timestamp = encrypted_message.decrypt_and_verify(cookie)
        raise TrivialSso::Error::LoginExpired if check_timestamp(timestamp)
        userdata
      rescue NoMethodError
        raise TrivialSso::Error::MissingConfig
      rescue ActiveSupport::MessageVerifier::InvalidSignature ||
             ActiveSupport::MessageEncryptor::InvalidMessage
        raise TrivialSso::Error::BadCookie
      end
    end

    # create an encrypted and signed cookie containing userdata and an expiry date.
    # userdata should be an array, and at minimum include a 'username' key.
    # using json serializer to hopefully allow future cross version compatibliity
    # (Marshall, the default serializer, is not compatble between versions)
    def self.cookie(userdata, exp_date = expire_date)
      begin
        raise TrivialSso::Error::MissingConfig    if sso_secret
        raise TrivialSso::Error::NoUsernameCookie if username(userdata)
        enc.encrypt_and_sign([userdata,exp_date.to_i])
      rescue NoMethodError
        raise TrivialSso::Error::MissingConfig
      end
    end

    def self.sso_secret
      Rails.configuration.sso_secret.blank?
    end

    def self.username(userdata)
      userdata['username'].blank?
    end

    def self.enc
      ActiveSupport::MessageEncryptor.new(
        Rails.configuration.sso_secret, :serializer => JSON
      )
    end

    #returns the exipiry date from now. Used for setting an expiry date when creating cookies.
    def self.expire_date
      9.hours.from_now
    end

    def self.check_timestamp(timestamp)
      (timestamp - DateTime.now.to_i) <= 0
    end

    def self.encrypted_message
      sso_secret = Rails.configuration.sso_secret
      raise TrivialSso::Error::MissingConfig if sso_secret.blank?
      ActiveSupport::MessageEncryptor.new(sso_secret, serializer: JSON)
    end

  end
end
