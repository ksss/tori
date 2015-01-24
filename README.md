Tori
===

Tori is a very very simple file uploader.

Tori dose nothing.

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

# default configure

```ruby
# Tori using hash function for decide filename.
#   Filename dependent on class name and `id` setting with `tori` method in class.
Tori.config.hash_method = ->(model) do
  Digest::MD5.hexdigest "#{model.class.name}/#{__send__(model.id.to_sym)}"
end

# File Store directory.
#   All file upload under here.
Tori.config.backend = Tori::Backend::FileSystem.new(Pathname("tmp/tori"))
```

You can change configure any time.

# future TODO

- support background S3 Storage
