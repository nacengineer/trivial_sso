module TrivialSso
  class UnWrap

    attr_accessor :cookie, :userdata, :timestamp, :sso_secret
    attr_reader   :data

    def initialize(opts = {})
      opts.each {|k,v| send("#{k}=".to_sym, v) if available_opts.include?(k.to_sym)}
    end

    def cookie=(value)
      @cookie = value
    end

    def data
      begin
        has_cookie?
        userdata, timestamp = encrypted_message.decrypt_and_verify(cookie)
      rescue NoMethodError
        raise TrivialSso::Error::MissingConfig
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        raise TrivialSso::Error::BadCookie
      rescue ActiveSupport::MessageEncryptor::InvalidMessage
        raise TrivialSso::Error::BadCookie
      end
    end

    def userdata=(value)
      self.userdata = value.is_a?(OpenStruct) ? value : OpenStruct.new(value)
    end

    def timestamp=(time)
      if (time - DateTime.now.to_i) <= 0
        # TODO check if we can raise Error::LoginExpired
        raise TrivialSso::Error::LoginExpired
      else
        self.timestamp = time
      end
    end

   private

    def has_cookie?
      if cookie.nil? || cookie.empty?
        raise TrivialSso::Error::MissingCookie
      else
        true
      end
    end

    def encrypted_message
      unless defined? Rails
        raise TrivialSso::Error::MissingRails
      end
      ActiveSupport::MessageEncryptor.new(sso_secret, serializer: JSON)
    end

    def available_opts
      [:cookie]
    end

  end
end
