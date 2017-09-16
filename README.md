Tori
===

[![Build Status](https://travis-ci.org/ksss/tori.svg?branch=master)](https://travis-ci.org/ksss/tori)

"(\\( ⁰⊖⁰)/)"

Tori is a very very simple file uploader.

Tori does nothing.

Only file upload to backend store.

You can upload file without alter database.

# Quick start on Rails

Gemfile

```
gem 'tori', require: 'tori/rails'
```

app/models/photo.rb

```ruby
class Photo < ActiveRecord::Base
  tori :image

  after_save do
    image.write if image.from?
  end

  after_destroy do
    image.delete
  end
end
```

app/controllers/photos_controller.rb

```ruby
class PhotosController < ApplicationController
  def new
    @photo = Photo.new
  end

  def create
    Photo.create(photo_params)
    redirect_to root_path
  end

  private

    def photo_params
      params.require(:photo).permit(:image)
    end
end
```

app/views/photos/new.html.slim

```ruby
= form_for @photo, multipart: true |f|
  = f.file_field 'image'
  = f.button 'Upload'
```

You can read file.

```ruby
photo.image.read #=> image bin
photo.image.exist? #=> exist check
photo.image.name #=> filename
```

# Attach example

Two image file upload to backend example.
defined method by `tori` method can define a key name for each by block.

```ruby
class Photo < ActiveRecord::Base
  tori :original_image do |model|
    "#{model.class}/original/#{model.original_filename}"
  end

  tori :striped_image do |model|
    "#{model.class}/striped/#{model.striped_filename}"
  end

  # customize backend each by `tori` method.
  tori :custom, to: Tori::Backend::FileSystem.new(Pathname("custom")) do |model|
    "#{__tori__}/#{id}"
  end
end

class PhotoController < ApplicationController
  def create
    original = params[:file]
    Tempfile.open("striped") { |striped|
      # image processing example
      MiniMagick::Tool::Convert.new { |c|
        c.strip
        c << original.path
        c << striped.path
      }

      # create record
      photo = Photo.create

      # set image file to model
      photo.original_image = original
      photo.striped_image = striped

      # write image file to backend
      photo.original_image.write
      photo.striped_image.write
    }
  end
end
```

# Default configure

[https://github.com/ksss/tori/blob/master/lib/tori.rb](https://github.com/ksss/tori/blob/master/lib/tori.rb)

You can change configure any time.
