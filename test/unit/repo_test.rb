require 'test_helper'

class RepoTest < ActiveSupport::TestCase

  def sut
    @sut ||= Repo.new(:name => "test_repo", :url => "https://domain/path/to/repo")
  end

  attr_reader :git_analyzer

  def setup
    @git_analyzer = Bugwatch::GitAnalyzer.new(sut.name, sut.url)
  end

  test "#git_analyzer creates GitAnalyzer with name and url" do
    Bugwatch::GitAnalyzer.expects(:new).with(sut.name, sut.url).returns(git_analyzer)
    assert_equal git_analyzer, sut.git_analyzer
  end

  test "#git_analyzer sets cache strategy to active record cache" do
    cache_strategy = ActiveRecordCache.new(sut)
    ActiveRecordCache.expects(:new).with(sut).returns(cache_strategy)
    assert_equal cache_strategy, sut.git_analyzer.caching_strategy
  end

  test "#git_analyzer creates GitAnalyzer with protocolized url if rule matches domain" do
    AppConfig.stubs(:git_domains).returns(['domain'])
    Bugwatch::GitAnalyzer.expects(:new).with(sut.name, "domain:/path/to/repo").returns(git_analyzer)
    sut.git_analyzer
  end

  test "#fix_cache returns cache of fix cache analyzer" do
    repo = stub('Grit::Repo')
    commit = commits(:test_commit)
    bug_fix = BugFix.new(:file => 'file.rb', :klass => "test", :function => "function", :commit => commit, :date_fixed => '2010-10-10')
    bugwatch_bug_fix = stub('Bugwatch::BugFix')
    fix_cache = Bugwatch::FixCache.new(10)
    sut.stubs(:bug_fixes).returns([bug_fix])

    Bugwatch::BugFix.expects(:new).with(:file => bug_fix.file, :klass => bug_fix.klass, :function => bug_fix.function,
                                        :date => bug_fix.date_fixed, :sha => bug_fix.commit.sha).returns(bugwatch_bug_fix)
    Grit::Repo.expects(:new).with(sut.path).returns(repo)
    Bugwatch::FixCacheAnalyzer.expects(:new).with(repo, [bugwatch_bug_fix]).returns(stub("FixCacheAnalyzer", :cache => fix_cache))
    assert_equal fix_cache, sut.fix_cache
  end

end
