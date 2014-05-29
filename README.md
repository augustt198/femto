# Femto

A tiny web framework.

## Installation

Add this to your Gemfile:
```ruby
gem 'femto', github: 'augustt198/femto'
```

## Usage

First, set up your views/templates folder:

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


_femto_ is the SI prefix for 10<sup>-15</sup>
