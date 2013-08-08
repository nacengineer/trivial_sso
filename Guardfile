# More info at https://github.com/guard/guard#readme

notification :tmux,
  :display_message => true,
  :timeout => 5, # in seconds
  :default_message_format => '%s >> %s',
  # the first %s will show the title, the second the message
  # Alternately you can also configure *success_message_format*,
  # *pending_message_format*, *failed_message_format*
  :line_separator => ' > ', # since we are single line we need a separator
  :color_location => 'status-left-bg' # to customize which tmux element will change color

group :frontend do

  guard :bundler do
    watch('Gemfile')
  end

  guard :livereload do
    watch(%r{^app/.+\.(erb|haml)})
    watch(%r{^app/helpers/.+\.rb})
    watch(%r{^public/.+\.(css|js|html)})
    watch(%r{^config/locales/.+\.yml})
  end
end

group :backend do

end

guard 'spork' do
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
end

rspec_opts = {
  cli: "--drb --format Fuubar --color --fail-fast"
}

guard 'rspec', rspec_opts do

  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb') { "spec" }
  watch(%r{^lib/trivial_sso/(.+)\.rb$}) { |m| "spec/lib/trivial_sso/#{m[1]}_spec.rb" }

end
