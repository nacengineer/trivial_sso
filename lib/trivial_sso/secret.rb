module TrivialSso
  class Secret

    attr_accessor :sso_secret

    def initialize(opts={})
      opts.each {|k,v| send("#{k}=".to_sym, v) if available_opts.include?(k.to_sym)}
    end

    def sso_secret=(value)
      # TODO Add something to verify value
      self.sso_secret = value if check_sso_secret(value)
    end

    private

    def check_sso_secret(value)
      !value.nil? || !value.empty? || (raise TrivialSso::Error::MissingSecret)
    end

    def available_opts
      [:sso_secret]
    end

  end
end
