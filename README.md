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

```
# Tori using hash function for decide filename.
# Filename dependent on class name and `id` setting with `tori` method in class.
Tori.config.hash_method = Digest::MD5.method(:hexdigest)


Tori.config.backend = Tori::Backend::FileSystem.new(Pathname("tmp/tori"))
```

You can change configure any time.

# Options

Change hash resource data.

```
class Photo < ActiveRecord::Base
  tori :image, id: :filename
  def filename
    "abc"
  end
end
```

This class never upload two file.

# future TODO

- support background S3 Storage
