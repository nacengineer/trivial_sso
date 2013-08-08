TrivialSso::UnWrap = Struct.new :data, :sso_secret do

  attr_reader :userdata, :timestamp

  def unwrap
    decode_data_and_timestamp
    userdata
  end

private

  def userdata=(value)
    @userdata = if value.has_key?('table')
        OpenStruct.new(value['table'])
      else
        value
      end
  end

  def timestamp=(time_as_int)
    if (time_as_int - Time.now.to_i) <= 0
      # TODO check if we can raise Error::LoginExpired
      raise TrivialSso::Error::LoginExpired
    else
      @timestamp = time_as_int
    end
  end

  def decode_data_and_timestamp
    begin
      has_data?
      self.userdata, self.timestamp = encrypted_message.decrypt_and_verify(data)
    rescue NoMethodError
      raise TrivialSso::Error::MissingConfig
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      raise TrivialSso::Error::BadData
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      raise TrivialSso::Error::BadData
    end
  end

  def has_data?
    if data.nil? || data.empty?
      raise TrivialSso::Error::MissingData
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

end
