##
# TODO: Split up tests
#
require 'test_helper'

class Minitest::Spec
  include Lotus::Assets::Helpers
end

describe 'Configuration DSL' do
  before do
    Lotus::Assets.configure do
      assets_path "#{Lotus::Assets.root}/test/fixtures"

      javascript_path 'javascripts'
      stylesheet_path 'stylesheets'

      path_prefix 'prefix/'

      to_file true
    end

    @assets = []
    assets_dirs = Dir["#{Lotus::Assets.configuration.assets_path}/*"]
    assets_dirs.each do |dir|
      @assets << Dir["#{dir}/*"]
    end

    @assets = @assets.flatten(1)
  end

  after do
    assets_path "#{Lotus::Assets.root}/test/fixtures"

    after_assets = []
    assets_dirs = Dir["#{assets_path}/*"]
    assets_dirs.each do |dir|
      after_assets << Dir["#{dir}/*"]
    end

    after_assets = after_assets.flatten(1)

    created = after_assets - @assets
    created.each do |file|
      system("rm #{file}")
    end

    Lotus::Assets.configuration.clear!
  end

  describe 'when including a file' do
    before do
      @stylesheet_tag = stylesheet 'application'
      @javascript_tag = javascript 'application'
    end

    it 'should contain the path prefix' do
      @stylesheet_tag.must_include 'prefix/'
      @javascript_tag.must_include 'prefix/'
    end

    it 'should return the proper html tag' do
      @stylesheet_tag.must_include 'link'
      @stylesheet_tag.must_include "rel='stylesheet'"
      @stylesheet_tag.must_include 'href'

      @javascript_tag.must_include 'script'
      @javascript_tag.must_include 'src'
    end

    it 'should contain the javascript / stylesheet path' do
      @stylesheet_tag.must_include 'stylesheets'
      @javascript_tag.must_include 'javascripts'
    end
  end

  describe 'when including a compiled file' do
    before do
      @stylesheet_tag = stylesheet 'compiled'
      @javascript_tag = javascript 'compiled'
    end

    it 'should include the already compiled file' do
      @stylesheet_tag.must_include 'link'
      @stylesheet_tag.must_include "rel='stylesheet'"
      @stylesheet_tag.must_include 'href'
      @stylesheet_tag.must_include 'compiled.css'

      @javascript_tag.must_include 'script'
      @javascript_tag.must_include 'src'
      @javascript_tag.must_include 'compiled.js'
    end
  end

  describe 'when including a nonexisting file' do
    it 'should raise a NoFilesFoundException' do
      lambda { stylesheet 'nonexisting' }.must_raise Lotus::Assets::FilesNotFoundException
      lambda { javascript 'nonexisting' }.must_raise Lotus::Assets::FilesNotFoundException
    end
  end
end