require 'rubygems'
require 'spork'
# uncomment the following line to use spork with the debugger
# require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV["RAILS_ENV"] ||= 'test'

  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start
  end

  require 'rails'
  require 'rspec/autorun'
  require 'rspec/mocks'
  require 'factory_girl'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  # Dir[File.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods

    config.mock_with :rspec

    config.order = "random"

    def profile_directory
      directory = "/tmp/trivial_sso"
      system("mkdir #{directory}") unless Dir.exist? directory
      directory
    end

  end
end

Spork.each_run do
  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start
  end
  FactoryGirl.reload
  RSpec.configure do |config|
    def svg_filename
      "/tmp/trivial_sso/profile-#{Time.now.localtime.strftime("%H%M%S")}.svg"
    end
  end
end
