module TrivialSso
  class Wrap

    attr_accessor :data, :cookie, :sso_secret

    def initialize(opts = {})
      opts.each {|k,v| send("#{k}=".to_sym, v) if available_opts.include?(k.to_sym)}
    end

    def data=(value)
      @data = value
    end

    def cookie
      begin
        sanity_check
        encryptor.encrypt_and_sign([data, expire_date])
      rescue NoMethodError
        raise TrivialSso::Error::MissingConfig
      end
    end

   private

    def sanity_check
      sso_secret && check_username
    end

    def encryptor
      ActiveSupport::MessageEncryptor.new(sso_secret, serializer: JSON)
    end

    def expire_date
      (9.hours.from_now).to_i
    end

    def check_username
      has_data? || (raise TrivialSso::Error::NoUsernameCookie)
    end

    def has_data?
      data && !(data.username.nil? || data.username.empty?)
    end

    def available_opts
      [:data, :cookie]
    end

  end
end
