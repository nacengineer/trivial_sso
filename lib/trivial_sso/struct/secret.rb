TrivialSso::Secret = Struct.new :sso_secret do

  def sso_secret=(value)
    # TODO Add something to verify value
    @sso_secret = value if check_sso_secret(value)
  end

  private

  def check_sso_secret(value)
    !value.nil? || !value.empty? || (raise TrivialSso::Error::MissingSecret)
  end

end
