gem 'slim-rails'
gem 'pg'

gem 'russian'
gem 'jquery-ui-rails'
gem 'jquery-turbolinks'

gem 'carrierwave'
gem 'mini_magick'

gem 'cocoon' # for nested forms
gem 'kaminari'
gem 'ransack', github: 'activerecord-hackery/ransack'

gem_group :development do
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rvm'
  gem 'bullet'
  gem 'quiet_assets'
end

gem_group :development, :test do
  # Rspec for tests (https://github.com/rspec/rspec-rails)
  gem 'rspec-rails'
  # Capybara for integration testing (https://github.com/jnicklas/capybara)
  gem 'capybara'
  gem 'capybara-webkit'
  # gem 'selenium-webdriver'
  # gem 'poltergeist'
  gem 'launchy'
  # FactoryGirl instead of Rails fixtures (https://github.com/thoughtbot/factory_girl)
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'faker'
  gem 'fuubar'
end

gem_group :production do
  gem 'unicorn'
  gem 'htmlcompressor', github: 'paolochiodi/htmlcompressor', branch: 'master'
  gem 'dalli'
end

# Install gems
run 'bundle install'

# Initialize rspec
run 'bundle exec rails generate rspec:install'
run "sed -i '/^# .*require f /s/^#//' spec/rails_helper.rb"
run "mkdir 'spec/support'"

inside('spec/support') do
  # add FactoryGirl support to rspec
  run 'cat << EOF >> factory_girl.rb
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
EOF'
  # DatabaseCleaner
  run 'cat << EOF >> database_cleaner.rb
RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
EOF'
  # Capybara
  run "cat << EOF >> capybara.rb
require 'capybara/rspec'
Capybara.javascript_driver = :webkit
EOF"
end

# Capybara

# Initialize guard
# ==================================================
run 'bundle exec guard init rspec'

# Clean up Assets
# ==================================================
# Use SASS extension for application.css
run 'mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss'
# Remove the require_tree directives from the SASS and JavaScript files.
# It's better design to import or require things manually.
run "sed -i '/require_tree/d' app/assets/javascripts/application.js"
run "sed -i '/require_tree/d' app/assets/stylesheets/application.scss"

# Ignore rails doc files, Vim/Emacs swap files, .DS_Store, and more
# ===================================================
run 'cat << EOF >> .gitignore
/.bundle
/db/*.sqlite3
/db/*.sqlite3-journal
/log/*.log
/tmp
database.yml
doc/
*.swp
*~
.project
.idea
.secret
.DS_Store
coverage/*
EOF'

# Git: Initialize
# ==================================================
after_bundle do
  git :init
  git add: '.'
  git commit: %( -m 'Initial commit' )
end
