gem "compass"

after_bundler do
  # Initialize project with Compass
  run "compass init rails . --syntax #{config['sass_syntax_preference']}"
  
  # Reference new CSS files in layout
  # [TODO] Implement for erb
  if recipes.include? 'haml'
    css_code = <<-CODE
    = stylesheet_link_tag 'screen.css', :media => 'screen, projection'
    = stylesheet_link_tag 'print.css', :media => 'print'
    /[if IE]
      = stylesheet_link_tag 'ie.css', :media => 'screen, projection'
    CODE
    
    gsub_file "app/views/layouts/application.html.haml", '= stylesheet_link_tag "application"', css_code
  end
  
  # Make Compass work with Heroku
  if recipes.include? 'heroku'
    append_file "config/compass.rb", "\ncss_dir = 'tmp/stylesheets'"
    
    compass_initializer = <<-COMPASSINIT
  
      require 'fileutils'
      FileUtils.mkdir_p(Rails.root.join("tmp", "stylesheets"))

      Rails.configuration.middleware.delete('Sass::Plugin::Rack')
      Rails.configuration.middleware.insert_before('Rack::Sendfile', 'Sass::Plugin::Rack')

      Rails.configuration.middleware.insert_before('Rack::Sendfile', 'Rack::Static',
          :urls => ['/stylesheets'],
          :root => "\#{Rails.root}/tmp")
            
    COMPASSINIT
    create_file "config/initializers/compass.rb", compass_initializer
  end
end
__END__

name: Compass
description: "Compass is an open-source CSS Authoring Framework"
author: amolk

exclusive: css_library
category: assets

config:
  - sass_syntax_preference:
      type: multiple_choice
      prompt: "Which syntax do you prefer?"
      choices:
        - ["CSS based (SCSS)", scss]
        - ["Indent based (SASS)", sass]
