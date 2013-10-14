module TrivialSso
  module Error

    # General Cookie Error
    class CookieError < RuntimeError
      def to_s
        "There was an error processing the Ophth Cookie"
      end
    end

    # Cookie can not be verified, data has been altered
    module BadData

      class Signature < CookieError
        def to_s
          "The data signature supplied was not valid."
        end
      end

      # Cookie can not be verified, data has been altered
      class Message < CookieError
        def to_s
          "The data supplied was not valid. i.e. bad cookie data given"
        end
      end

      class Given < CookieError
        def to_s
          <<-HERE
          The data supplied is useless to me. i.e. Can't Wrap or Unwrap.
          Try passing me some good data.
          HERE
        end
      end

      # Cookie is missing
      class Missing < CookieError
        def to_s
          "No data was given."
        end
      end

    end

    # cookie is no longer valid
    class LoginExpired < CookieError
      def to_s
        "Login cookie has expired!"
      end
    end

    # Cookie is lacking a username.
    class NoUsernameData < CookieError
      def to_s
        "Need username to create cookie"
      end
    end

    # Missing configuration value.
    class MissingRailsConfig < CookieError
      def to_s
        <<-HERE
        Missing secret configuration for cookie, need to define
        config.sso_secret
        HERE
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


    class BadExpireTime < CookieError
      def to_s
        <<-HERE
        The expire_time is useless to me. i.e. its not an Time object
        transormed to integer time. Please retry with good data.
        HERE
      end
    end

    module Mode
      class Wrong < CookieError
        def to_s
          "Can't use same object to decode and encode"
        end
      end
    end

  end
end
