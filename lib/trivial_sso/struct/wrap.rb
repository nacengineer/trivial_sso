TrivialSso::Wrap = Struct.new :data, :sso_secret, :expire_time do

  attr_reader :wrap

  def wrap
    begin
      encryptor.encrypt_and_sign([data.to_h, expire_time]) if sanity_check?
    rescue NoMethodError
      raise TrivialSso::Error::MissingConfig
    end
  end

 private

  def sanity_check?
    sso_secret && check_username || false
  end

  def encryptor
    @encryptor ||=
      ActiveSupport::MessageEncryptor.new(sso_secret, serializer: JSON)
  end

  def check_username
    has_data? || (raise TrivialSso::Error::NoUsernameData)
  end

  def has_data?
    data && !(data.username.nil? || data.username.empty?)
  end

end
