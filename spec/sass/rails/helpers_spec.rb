# frozen_string_literal: true

require 'spec_helper'
require 'sprockets'
require 'sass/rails'
require 'active_support/core_ext/string/starts_ends_with'
require 'active_support/core_ext/string/strip'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Sass::Rails::Helpers' do
  # rubocop:enable Metrics/BlockLength
  let(:name_with_digest) { 'my_image-abcdef123456.png' }
  let(:sprockets) { Sprockets::Environment.new }
  let(:sass_rails_3?) { Sass::Rails::VERSION.starts_with?('3') }
  let(:sass_rails_4?) { Sass::Rails::VERSION.starts_with?('4') }
  let(:template_class) { sass_rails_4? ? Sprockets::ScssTemplate : Sass::Rails::ScssTemplate }
  let(:sprockets_context) { sprockets.context_class.new(*context_args) }

  let(:context_args) do
    if sass_rails_3? || sass_rails_4?
      [sprockets.index, 'ignored', Pathname.new(File.new(__FILE__))]
    else
      [{ filename: __FILE__, metadata: {}, environment: sprockets.index }]
    end
  end

  let(:template) do
    template_class.new do
      "div { background-image: #{image_css} }"
    end
  end

  let(:expected_result) do
    <<-CSS.strip_heredoc
    div {
      background-image: #{expected_image_url}
    }
    CSS
  end

  subject { template.render(sprockets_context, 'abc.css') }

  def define_sass_config(object)
    object.instance_eval do
      def sass_config
        {
          cache: false,
          line_comments: false,
          preferred_syntax: :scss,
          style: :expanded
        }
      end
    end
  end

  def configure_sprockets_context_for_sass_rails_3
    allow(sprockets_context).to receive(:asset_environment).and_return(sprockets)
    %i[compile_assets? digest_assets?].each do |method_name|
      allow(sprockets_context).to receive(method_name).and_return(true)
    end
  end

  def configure_sprockets_for_sass_rails_3
    sprockets_config_options = { assets_dir: '', asset_host: nil, relative_url_root: '' }
    sprockets_config = double('SprocketsConfig', sprockets_config_options)
    allow(sprockets_context).to receive(:config).and_return(sprockets_config)
  end

  def configure_rails_for_sass_rails_3
    rails_config = double('RailsConfig', assets: double(prefix: '/v1/assets'))
    allow(::Rails).to receive(:application) { double(config: rails_config) }
  end

  def configure_sprockets_context_for_sass_rails_4
    allow(sprockets_context).to receive(:assets_environment).and_return(sprockets)
    allow(sprockets_context).to receive(:digest_assets).and_return(true)
  end

  def stub_manifest_for_sass_rails_3
    allow(sprockets_context).to receive(:asset_digests)
      .and_return('my_image.png' => name_with_digest)
  end

  def stub_manifest_for_sass_rails_4
    allow(sprockets_context).to receive(:asset_digest_path).with('my_image.png')
                                                           .and_return(name_with_digest)
  end

  def stub_manifest
    if sass_rails_3?
      stub_manifest_for_sass_rails_3
    elsif sass_rails_4?
      stub_manifest_for_sass_rails_4
    else
      allow(sprockets_context).to receive(:resolve_asset_path).with('my_image.png', nil)
                                                              .and_return(name_with_digest)
    end
  end

  def configure_sprockets
    if sass_rails_3?
      configure_sprockets_context_for_sass_rails_3
      configure_sprockets_for_sass_rails_3
      configure_rails_for_sass_rails_3
    elsif sass_rails_4?
      configure_sprockets_context_for_sass_rails_4
    end
  end

  before(:each) do
    define_sass_config(sass_rails_3? || sass_rails_4? ? sprockets.context_class : sprockets_context)

    if sass_rails_3?
      sprockets_context.class_eval do
        include ::Sprockets::Helpers::RailsHelper
        include ::Sprockets::Helpers::IsolatedHelper
      end
    else
      sprockets_context.class_eval do
        include ::Sprockets::Rails::Helper
        self.assets_prefix = '/v1/assets'
      end
    end

    configure_sprockets
    stub_manifest
  end

  describe '#image-url' do
    context 'without anchor or query string' do
      let(:image_css) { 'image-url("my_image.png");' }
      let(:expected_image_url) { 'url(/v1/assets/my_image-abcdef123456.png);' }

      it { should eq(expected_result) }
    end
  end

  describe '#image-path' do
    context 'without anchor or query string' do
      let(:image_css) { 'url(image-path("my_image.png"));' }
      let(:expected_image_url) { 'url("/v1/assets/my_image-abcdef123456.png");' }

      it { should eq(expected_result) }
    end
  end
end
