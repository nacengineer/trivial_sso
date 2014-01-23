[![Code Climate](https://codeclimate.com/github/nacengineer/trivialsso.png)](https://codeclimate.com/github/nacengineer/trivialsso)

## TrivialSso

A very simple gem to help with creating and reading cookies across multiple sites in a Ruby on Rails application.

This allows for a simple single sign on solution among sites within the same domain.

This does *not* work across domains.

## Requirements

- ruby 1.9

## Getting Started

Add the gem to your Gemfile

    gem 'trivial_sso'

Install the gem

    bundle install

After you've installed the gem, you need to generate a configuration file.

    rails g trivial_sso:install

This will create an initializer file with a shared secret. You need to modify this to a big long string of characters. Keep this safe from others as they could forge cookies for your sites if they get ahold of this string. All sites that use the single sign on must have this same shared secret for the cookies to properly interoperate.

## Creating an encrpyted string
### Uses [ActiveSupport::MessageEncryptor](http://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html)

A encrypted and signed string is created using of data supplied to it via a [ruby Hash](http://www.ruby-doc.org/core-2.0/Hash.html).

This only requirement is that the Hash must contain a **username** key.

When you create the encrypted string an expire time is added to the payload. You have the option of either providing one, or a default of 9 hours from the current time will be used.

Note: Setting the [ActionDispatch#expires](http://api.rubyonrails.org/classes/ActionDispatch/Cookies.html) on the cookie is just a convenience to make sure it gets cleared by the browser.

The actual expiration date that is enforced by the application  is what is encoded in the cookie.4

Essentiall it is all boiled down to the follwoing...

### create a userdata hash

```ruby
# Create a hash of data we want to store in the cookie.
userdata = {
  "username" => current_user.login,
  "display"  => current_user.display_name,
  "groups"   => current_user.memberof
}

#### Generate the cookie data with Api.encode
cookie = TrivialSso::Api.encode(userdata)

#### Set the cookie
cookies[:sso_login] = {
  :value    => cookie,
  :expires  => TrivialSso::Login.expire_date,
  :domain   => 'mydomain.com',
  :httponly => true
}
```

The above code creates a hash of data we will be putting in the cookie, generates the cookie, and then sets the cookie in the browser.

### Decoding a cookie

Retrieve the contents of the cookie by calling Api.decode

```ruby
@userdata = TrivialSso::Api.decode(cookies[:sso_login])
```

This will return the originally encoded data as a __Hash__ with string keys.

NOTE: This will throw an exception if the cookie has been tampered with, or if the expiration date has passed.

## Sample code for application_controller

Here are some methods you can add into your application controller to authenticate against the cookie.

```ruby
# If there is a problem with the cookie, redirect back to our central login server.
rescue_from TrivialSso::CookieError do |exception|
  redirect_to 'https://login.mydomain.com/'
end

# authorize our users based on the cookie.
before_filter :auth_user!

# authenticate a user and set @current_user
def auth_user!
  cu = current_user

  # Check for authorization based on "groups" data that was put in the cookie
  # by the central login application.
  # you could also skip this check and just return true if the cookie is valid.
  if cu['groups'].include? "ALLOWED_GROUP"    #all lower case
    @current_user = cu
    true
  else
    render :file => "#{Rails.root}/public/403", :formats => [:html], :status => 403, :layout => false
  end

  false
end

# our current_user decodes the cookie.
def current_user
  TrivialSso::Api.decode(cookies[:sso_login])
end

# Define the name we want to record in paper_trail (if using)
def user_for_paper_trail
  if @current_user.blank?
    "anonymous"
  else
    @current_user['username']
  end
end
```
