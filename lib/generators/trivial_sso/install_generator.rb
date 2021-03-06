module TrivialSso
	module Generators
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path("../../templates",__FILE__)

			desc "Creates a sso_secret initalizer"

			def copy_initializer
				template "sso_secret.rb", "config/initializers/sso_secret.rb"
			end

			def show_readme
				readme "README"
			end

		end
	end
end
