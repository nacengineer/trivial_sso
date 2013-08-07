module TrivialSso
  module Error

    # General Cookie Error
    class CookieError < RuntimeError
      def to_s
        "There was an error processing the Ophth Cookie"
      end
    end

    # Cookie can not be verified, data has been altered
    class BadCookie < CookieError
      def to_s
        "Login cookie can not be verified!"
      end
    end

    # cookie is no longer valid
    class LoginExpired < CookieError
      def to_s
        "Login cookie has expired!"
      end
    end

    # Cookie is missing
    class MissingCookie < CookieError
      def to_s
        "Login cookie is missing!"
      end
    end

    # Cookie is lacking a username.
    class NoUsernameCookie < CookieError
      def to_s
        "Need username to create cookie"
      end
    end

    # Missing configuration value.
    class MissingConfig < CookieError
      def to_s
        "Missing secret configuration for cookie, need to define config.sso_secret"
      end
    end

    # Missing configuration value.
    class MissingSecret < CookieError
      def to_s
        "Missing secret, need to define sso_secret"
      end
    end

    # Missing Rails configuration value.
    class MissingRails < CookieError
      def to_s
        "Rails isn't loaded, you need Rails to use trivial_sso"
      end
    end

  end
end
