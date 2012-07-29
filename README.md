# Rack::Svn

rack application (not a middleware) serves contents in a svn repository directly ( like Rack::File)

## Installation

Add this line to your application's Gemfile:

    gem 'rack-svn'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-svn

## Usage

config.ru

    run Rack::Svn::Directory

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
