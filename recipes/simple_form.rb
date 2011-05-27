gem "simple_form"
after_bundler do
  generate 'simple_form:install'

  inject_into_file "config/initializers/generators.rb", :after => "Rails.application.config.generators do |g|\n" do
    <<-eos

      # simple_form
      g.stylesheets false
      g.form_builder :simple_form
    eos
  end

end
__END__

name: simple_form
description: "Use simple_form form generator'"
author: amolk

category: templating
exclusive: form_generator
