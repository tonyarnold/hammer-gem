#!/usr/bin/env ruby
require "test_helper"
require 'parsers/modules/extensions'
require 'parsers/modules/finding_files'

parsers_path = File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'lib', 'hammer', 'parsers', '**/*.rb')
Dir[parsers_path].each {|file| require file; }

class FindingFilesTest < Test::Unit::TestCase

  class Thing
    include Hammer::FindingFiles
  end

  setup do
    @object = Thing.new
    assert_equal @object.send(:filenames) , []
  end

  def test_find_files
    @object.stubs(:filenames).returns(['index.html', 'index.js', '_include.html'])
    {
      ['index', 'html'] => ['index.html'],
      ['index', 'js'] => ['index.js'],
      ['index', 'css'] => [],
      ['*', 'html'] => ['index.html', '_include.html'],
      ['include.html', 'html'] => ['_include.html'],
      ['include', 'html'] => ['_include.html']
    }.each do |set, result|
      query, extension = set
      assert_equal @object.find_files(query, extension), result
    end
  end

  def test_regex_for
    assert_equal(/(^|\/|_)index\.(html|haml|md|slim)/, @object.regex_for('index', 'html'))
    assert_equal(/(^|\/|_)index/, @object.regex_for('index', nil))
  end

end