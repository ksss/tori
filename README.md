Tori
===

"(\\( ⁰⊖⁰)/)"

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

You can read file.

```ruby
photo.image.read #=> image bin
photo.image.exist? #=> exist check
photo.image.to_s #=> filename
```

# Custom configure example

```ruby
# create and save files to public/tori dir.
Tori.config.backend = Tori::Backend::FileSystem(Pathname("public/tori"))

# filename decided by model.class.name,id,created_at and hidden words.
Tori.config.filename_callback = ->(model){
  Digest::MD5.hexdigest "#{model.class.name}/#{model.id}/#{model.created_at}+#{ENV['TORI_MAGICKWORD']}"
}
```

# Default configure

[https://github.com/ksss/tori/blob/master/lib/tori.rb](https://github.com/ksss/tori/blob/master/lib/tori.rb)

You can change configure any time.

# future TODO

- support background S3 Storage
