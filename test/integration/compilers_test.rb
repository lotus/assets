require 'test_helper'

describe 'Compilers' do
  before do
    root = __dir__ + '/../fixtures'
    tmp  = Pathname.new(__dir__ + '/../../tmp')
    tmp.rmtree

    Lotus::Assets.configure do
      compile     true
      destination tmp.join('public')

      define :javascript do
        sources << [
          "#{ root }/javascripts"
        ]
      end
    end

    @config = Lotus::Assets.configuration
  end

  after do
    @config.reset!
  end

  it 'copies javascript asset from source to destination' do
    result = CompilerView.new.render
    result.must_include %(<script src="/assets/greet.js" type="text/javascript"></script>)

    target = @config.destination.join('assets/greet.js')
    target.read.must_match %(alert("Hello!");)
    target.stat.mode.to_s(8).must_equal('100644')
  end

  it 'compiles coffeescript asset' do
    result = CompilerView.new.render
    result.must_include %(<script src="/assets/hello.js" type="text/javascript"></script>)

    target = @config.destination.join('assets/hello.js')
    target.read.must_match %(alert("Hello, World!");)
    target.stat.mode.to_s(8).must_equal('100644')
  end

  it "won't compile/copy if the source hasn't changed" do
    result = UnchangedCompilerView.new.render
    result.must_include %(<script src="/assets/unchanged.js" type="text/javascript"></script>)

    compiled    = @config.destination.join('assets/unchanged.js')
    content     = compiled.read
    modified_at = compiled.mtime

    content.must_match %(alert("Still the same");)

    sleep 1

    UnchangedCompilerView.new.render
    compiled = @config.destination.join('assets/unchanged.js')

    compiled.read.must_match %(alert("Still the same");)
    compiled.mtime.to_i.must_equal modified_at.to_i
  end

  it 'raises an error in case of missing source' do
    sources   = @config.asset(:javascript).sources.map(&:to_s).join(', ')
    exception = -> { MissingAssetSourceView.new.render }.must_raise(Lotus::Assets::MissingAsset)

    exception.message.must_equal("Missing asset: `missing.js' (sources: #{ sources })")
  end

  it 'raises an error in case of unknown compiler engine' do
    exception = -> { UnknownAssetEngineView.new.render }.must_raise(Lotus::Assets::UnknownAssetEngine)
    exception.message.must_equal("No asset engine registered for `ouch.js.unknown'")
  end
end