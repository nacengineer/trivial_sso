module TrivialSso
  class Login

    attr_accessor :data, :secret, :expire_time
    attr_reader :wrap, :unwrap, :mode

    def initialize(opts = {})
      opts[:expire_time] = default_expire unless opts[:expire_time]
      opts[:secret]      = sso_secret     unless opts[:secret]
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
      mode_set?
      raise Error::WrongMode unless mode == __method__
      TrivialSso::Wrap.new(data, sso_secret, expire_time).wrap
    end

    def unwrap
      mode_set?
      raise Error::WrongMode unless mode == __method__
      TrivialSso::UnWrap.new(data, sso_secret).unwrap
    end

    def sso_secret
      TrivialSso::Secret.new(secret).sso_secret
    end

   private


    def mode_set?
      raise Error::BadDataSupplied  if mode.nil? || mode.empty?
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

    def check_for_rails
      defined?(Rails) || (raise Error::MissingRails)
    end

    def sso_secret
      check_for_rails ? Rails.configuration.sso_secret : SecureRandom.hex(64)
    end

    def default_expire
      (Time.now + 32400).to_i # 9 hours from now
    end

    def available_opts
      [:data, :secret, :expire_time]
    end

  end
end
