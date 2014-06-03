# Femto

A tiny web framework.

## Installation

```sh
$ gem install femto
```

If you're using bundler, add this to your Gemfile:
```ruby
gem 'femto', github: 'augustt198/femto'
```

## Usage

First, setup your views/templates folder:

```ruby
# For example
@templates_dir = File.join __dir__, 'views'
```

Handle requests by passing a path and block to a HTTP verb method.

```ruby
get '/' do
    render 'home'
end

# The 'view' option automatically renders a template!
get '/about', view: 'about_page' do
    # You can create variables to use in your views
    @copyright_date = '2014'
end
```

The render method tries to render a view if a String is passed, but other
content types can be rendered:
```ruby
get '/status' do
    render json: {system_status: 'good'}
end
```

### Models
To use models, first you need specify the model adapter. `MongoAdapter` is the only model adapter currently:

```ruby
# Connect to database
Femto::Model::MongoAdapter.connect host: 'localhost', port: 27107, db: 'test'
Femto::Model.adapter = Femto::Model::MongoAdapter
```

Add models with the `model` method, for example:
```ruby
model :user do |m|
    m.field :username
    m.field :password
    m.field :created_at
end
```

This will create the class `User`. Use the model class to find, update, and insert:
```ruby
user = User.new(username: 'foo', password: 'bar')
user.save # Saves to database or updates if it already exists
User.find # => [#<User:0x007fcb5bef8840>]
```

The parameter passed to the block in the `model` method is the `ModelCreator`.
You can add your own methods to the model:
```ruby
model :user do |m|
    m.set_method('confirmed?') { false }
end
```

You can also change the storage name of the model. The default is the model name + "s".
```ruby
model :category do |m|
    m.storage :categories
end
```

Fields can be validated before saving by using `ModelCreator#validate`:
```ruby
model :user do |m|
    m.validate(:password) { |val| val.length > 8 }
end
```

### Layouts

You can define application-wide views by using the layout method.
```ruby
layout view: 'layout' do
    # This block would be called every page load
end
```

An example layout view:
```html
<div class="container">
    <!-- the yield keyword renders the current view -->
    <%= yield %>
</div>
```

### Custom Renderers
Femto comes with the renderers `:json`, `:pretty_json`, and `:text`, but you can easily
add custom renderers.


For instance:
```ruby
Femto::Renderer.renderer :custom do |content|
    ['text/plain', content.to_s.reverse]
end
```

All renderers should return an array with the `Content-Type` at position `[0]`, and the actual content
at position `[1]`.

### [App Example](https://github.com/augustt198/femto/tree/master/example)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


_femto_ is the SI prefix for 10<sup>-15</sup>
