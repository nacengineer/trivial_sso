module TrivialSso
  class Login

    attr_accessor :data, :cookie, :secret
    attr_reader :wrap, :unwrap

    def initialize(opts = {})
      opts[:secret] = SecureRandom.hex(64) unless opts[:secret]
      binding.pry
      opts.each {|k,v| send("#{k}=".to_sym, v) if available_opts.include?(k.to_sym)}
    end

    def data=(value)
      @data = OpenStruct.new(value)
    end

    def wrap
      Wrap.new({data: data, sso_secret: sso_secret}).cookie
    end

    def unwrap
      UnWrap.new({cookie: cookie, sso_secret: sso_secret}).data
    end

    def sso_secret
      Secret.new({sso_secret: secret}).sso_secret
    end

   private

    def check_for_rails
      defined?(Rails) || (raise TrivialSso::Error::MissingRails)
    end

    def get_rails_sso_secret
      Rails.configuration.sso_secret
    end

    def available_opts
      [:data]
    end

  end
end
