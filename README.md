# Coverage::Helpers

This gem provides some helper methods to manipulate the coverage results measured by `Coverage.result` of the `coverage.so` library.

## APIs

Currently, the following methods are available:

* `Coverage::Helpers.merge(*covs)`: Sum up all coverage results.
* `Coverage::Helpers.diff(cov1, cov2)`: Extract the coverage results that is covered by `cov1` but not covered by `cov2`.
* `Coverage::Helpers.sanitize(cov)`: Make the coverage result able to `Marshal#dump`.  (See the Notes section.)
* `Coverage::Helpers.save(filename, cov)`: Save the coverage result to a file.
* `Coverage::Helpers.load(filename)`:  Load the coverage result from a file.
* `Coverage::Helpers.to_lcov_info(cov)`: Translate the result into LCOV info format.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'coverage-helpers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install coverage-helpers

## Usage

Here is an example:

```
$ cd example
$ ruby measure.rb -o cov1.dat -l cov1.info -- file.rb 1
$ genhtml --branch-coverage cov1.info -o cov1-lcov
$ open cov1-lcov/index.html
```

Note that `genhtml` is an executable of LCOV that visualizes LCOV info data by HTML view.

You can merge the coverage results of multiple runs:

```
$ ruby measure.rb -o cov1.dat -l cov1.info -- file.rb 1
$ ruby measure.rb -o cov2.dat -l cov2.info -a cov1.dat -- file.rb 2
$ genhtml --branch-coverage cov2.info -o cov2-lcov
$ open cov2-lcov/index.html
```

You can also check the newly covered code:

```
$ ruby measure.rb -o cov1.dat -l cov1.info -- file.rb 1
$ ruby measure.rb -o cov2.dat -l cov2.info -b cov1.dat -- file.rb 2
$ genhtml --branch-coverage cov2.info -o cov2-lcov
$ open cov2-lcov/index.html
```

See `example/measure.rb` in detail.

## Notes

There are two formats of `Coverage.result`.  One is an old format, which Ruby 2.4 or before returns.  It can contain only line coverage.  The other is a new format, which Ruby 2.5 or later generates.  It can contain line, branch, and method coverage.  All methods of this gem support both format.

Method coverage data contains a class defined a measured method.  The class may be a singleton class, which `Marshal.dump` cannot handle.  This is why this gem provides `sanitize`.  The method replaces all singleton classes with its string representation by using `to_s`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mame/coverage-helpers.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
