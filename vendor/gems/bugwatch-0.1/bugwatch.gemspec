Gem::Specification.new do |s|
  s.name = 'bugwatch'
  s.version = '0.1'
  s.date = '2012-02-13'

  s.summary = "bugwatch"
  s.description = "will get to this later"

  s.authors = ["Jacob Richardson"]
  s.email = 'jacob.ninja.dev@gmail.com'

  s.require_paths = %w[lib]

  s.add_dependency('grit')
  s.add_dependency('sexp_processor', '~> 3.0')
  s.add_dependency('ruby_parser', '~> 2.0')
  s.add_dependency('sinatra')
  s.add_dependency('resque')

  # = MANIFEST =
  s.files = %w[
    bugwatch.gemspec
    lib/bugwatch.rb
    lib/bugwatch/bug_fix.rb
    lib/bugwatch/commit.rb
    lib/bugwatch/diff.rb
    lib/bugwatch/exception_data.rb
    lib/bugwatch/exception_tracker.rb
    lib/bugwatch/file_helper.rb
    lib/bugwatch/file_system_cache.rb
    lib/bugwatch/fix_cache.rb
    lib/bugwatch/fix_cache_analyzer.rb
    lib/bugwatch/git_analyzer.rb
    lib/bugwatch/hot_spot.rb
    lib/bugwatch/method_parser.rb
    lib/bugwatch/repo.rb
  ]
  # = MANIFEST =

end
