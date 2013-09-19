module TrivialSso
  class Login

    attr_accessor :data, :secret, :expire_time, :struct
    attr_reader   :wrap, :unwrap, :mode, :secret

    def initialize(opts = {})
      opts[:expire_time] = default_expire unless opts[:expire_time]
      opts[:secret]      = default_secret unless opts[:secret]
      opts.each {|k,v| send("#{k}=".to_sym, v) if available_opts.include?(k.to_sym)}
    end

    def expire_time=(value)
      @expire_time = time_or_default(value) if time_value_good?(value)
    end

    def data=(value)
      if value.is_a?(String)
        @mode, @data = :unwrap, value
      elsif value.is_a?(Hash)
        @mode, @data = :wrap, OpenStruct.new(value)
      else
        raise Error::BadDataSupplied
      end
    end

    def wrap
      check_mode_set
      raise Error::WrongMode unless mode == __method__
      TrivialSso::Wrap.new(data, sso_secret, expire_time).wrap
    end

    def unwrap
      check_mode_set
      raise Error::WrongMode unless mode == __method__
      response = TrivialSso::UnWrap.new(data, sso_secret).unwrap
      struct ? OpenStruct.new(response) : response
    end

    def sso_secret
      TrivialSso::Secret.new(secret).sso_secret
    end

   private

    def default_secret
      get_defined_sso_secret || SecureRandom.hex(64)
    end

    def get_defined_sso_secret
      if rails_sso_secret_exists?
        Rails.configuration.sso_secret
      elsif defined? Rails
        raise Error::MissingRailsConfig
      else
        false
      end
    end

    def rails_sso_secret_exists?
      defined?(Rails) && Rails.configuration.sso_secret
    end

    def check_mode_set
      raise Error::BadDataSupplied if mode.nil? || mode.empty?
    end

    def time_value_good?(value)
      if (value.is_a?(Integer) || value.is_a?(String)) && value.to_s.length == 10
        true
      else
        raise Error::BadExpireTime
      end
    end

    def time_or_default(value)
      value.to_i.nonzero? ? value.to_i : default_expire
    end

    def default_expire
      (Time.now + 32400).to_i # 9 hours from now
    end

    def available_opts
      [:data, :secret, :expire_time]
    end

  end
end
