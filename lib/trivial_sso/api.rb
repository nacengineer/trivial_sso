module TrivialSso
  class Api

    class <<self

      def encode(data, expire_time = nil, secret = nil)
        TrivialSso::Login.new(
          {data: data, expire_time: expire_time, secret: secret}
        ).wrap
      end

      def decode(data, secret = nil)
        TrivialSso::Login.new(
          {data: data, secret: secret}
        ).unwrap
      end

    end

  end
end
