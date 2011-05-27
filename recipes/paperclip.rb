gem "paperclip"

add_s3_support = config['add_s3_support'] || recipes.include?('heroku')
if (add_s3_support)
  gem "aws-s3"
  
  paperclip_initializer = <<-PAPERCLIPINIT
  #
  # Set the base options we use for Paperclip's has_attached_file
  #

  BASE_HAS_ATTACHED_FILE_OPTIONS = {
    :convert_options => { :all => ["-strip"] },
    :processors      => [ :orient, :thumbnail ],
  }

  s3_credentials = {
    :access_key_id => ENV['S3_KEY'],
    :secret_access_key => ENV['S3_SECRET']
  }

  if Rails.env.production?
    BASE_HAS_ATTACHED_FILE_OPTIONS.merge!({
      :storage        => :s3,
      :s3_credentials => s3_credentials,
      :s3_host_alias => "s3.amazonaws.com/assets.#{app_name}.com",
      :bucket         => "assets.#{app_name}.com",
      :url            => ":s3_alias_url",
      :path           => "/:class/:attachment/:id/:style/:safe_filename",
    })
  elsif Rails.env.staging?
    BASE_HAS_ATTACHED_FILE_OPTIONS.merge!({
      :storage        => :s3,
      :s3_credentials => s3_credentials,
      :s3_host_alias  => "s3.amazonaws.com/staging-assets.#{app_name}.com",
      :bucket         => "staging-assets.#{app_name}.com",
      :url            => ":s3_alias_url",
      :path           => "/:class/:attachment/:id/:style/:safe_filename",
    })
  elsif Rails.env.test?
      BASE_HAS_ATTACHED_FILE_OPTIONS.merge!({          
        :storage => :filesystem,
        :url             => "/system/test/:class/:attachment/:id/:style/:safe_filename",
        :path            => ":rails_root/public:url",
      })
    else
      BASE_HAS_ATTACHED_FILE_OPTIONS.merge!({
        :storage => :filesystem,
        :url             => "/system/:class/:attachment/:id/:style/:safe_filename",
        # uncommment to see production images in development (if you have a production database)
    #    :url             => "http://assets.kingofweb.com/:class/:attachment/:id/:style/:safe_filename",
        :path            => ":rails_root/public:url",
      })
    end


    #
    # Workaround an issue where Paperclip invokes ImageMagick's "-auto-orient"
    # option after resizing an image, instead of before. To fix this,
    # we add a processor extension that runs "-auto-orient" first.
    # For details, see https://github.com/thoughtbot/paperclip/issues/issue/179?authenticity_token=5a1b7b93df1621ed8ef3d37d$
    #
    module Paperclip
      class Orient < Paperclip::Processor
        def initialize(file, options = {}, *args)
          @file = file
        end

        def make( *args )
          dst = Tempfile.new([@basename, @format].compact.join("."))
          dst.binmode

          Paperclip.run('convert',"\#{File.expand_path(@file.path)} -auto-orient \#{File.expand_path(dst.path)}")

          return dst
        end
      end
    end

    # Fix non-alphanumeric chars in filenames due to encoding issues
    # REF: http://groups.google.com/group/paperclip-plugin/browse_thread/thread/ac38aa33082efa11?pli=1
    Paperclip.interpolates :safe_filename do |attachment, style|
      filename(attachment, style).to_slug_filename
    end

    Paperclip.interpolates :user_profile_fallback_url do |attachment,style|
      attachment.instance.user.profile_image.url
    end
  
  PAPERCLIPINIT
  
  create_file "config/initializers/paperclip.rb", paperclip_initializer
end

__END__

name: Paperclip
description: "Easy file attachment management for ActiveRecord"
author: amolk

category: other

config:
  - add_s3_support:
      type: boolean
      prompt: "Store paperclip attachements to Amazon S3 in production (forced if using heroku)?"
