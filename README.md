# Sass::Rails::QueryStringAndAnchorFix

sass-rails' asset helper functions (font-url, font-path, image-url, image-path, etc.) pass their full argument along to sprockets to look up in the sprockets manifest.  When the argument is a URL that concludes with a query string or an anchor tag, neither sass-rails 3 nor sprockets 2 strips it before looking up the digest.  This results in sprockets not finding the digest, and the non-digest URL is used instead.

This issue occurs in sass-rails < 4, and it is resolved by this gem.  For later versions of sass-rails, this gem is unnecessary.

## Installation / Usage

Add this line to your application's Gemfile, in the same group as sass-rails:

```ruby
gem 'sass-rails-query_string_and_anchor_fix'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sass-rails-query_string_and_anchor_fix

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/on-site/sass-rails-query_string_and_anchor_fix.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
