gem 'sass'

if recipes.include? 'git'
  append_file ".gitignore", "public/stylesheets/*.css"
end
__END__

name: SASS
description: "Utilize SASS (through the HAML gem) for really awesome stylesheets!"
author: mbleigh

exclusive: css_replacement 
category: assets
tags: [css]
