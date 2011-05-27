gem "factory_girl_rails", :group => [ :development, :test ]

after_bundler do
  inject_into_file 'spec/spec_helper.rb', "\nrequire 'factory_girl'", :after => "require 'rspec/rails'"

  inject_into_file "config/initializers/generators.rb", :after => "Rails.application.config.generators do |g|\n" do
    <<-eos

      # factory_girl
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    eos
  end
end

__END__

name: Factory girl
description: "Use factory_girl to manage test fixtures"
author: amolk

exclusive: fixture_replacement
category: testing

