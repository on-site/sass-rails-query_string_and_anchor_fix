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
  let(:template_class) { Sass::Rails::ScssTemplate }
  let(:sprockets_context) { sprockets.context_class.new(*context_args) }

  let(:context_args) do
      [sprockets.index, 'ignored', Pathname.new(File.new(__FILE__))]
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

  def define_sass_config
    sprockets.context_class.instance_eval do
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

  def configure_sprockets_context
    allow(sprockets_context).to receive(:asset_environment).and_return(sprockets)
    %i[compile_assets? digest_assets?].each do |method_name|
      allow(sprockets_context).to receive(method_name).and_return(true)
    end
  end

  def configure_sprockets
    sprockets_config_options = { assets_dir: '', asset_host: nil, relative_url_root: '' }
    sprockets_config = double('SprocketsConfig', sprockets_config_options)
    allow(sprockets_context).to receive(:config).and_return(sprockets_config)
  end

  def configure_rails
    rails_config = double('RailsConfig', assets: double(prefix: '/v1/assets'))
    allow(::Rails).to receive(:application) { double(config: rails_config) }
  end

  def stub_manifest
    allow(sprockets_context).to receive(:asset_digests)
      .and_return('my_image.png' => name_with_digest)
  end

  before(:each) do
    define_sass_config

      sprockets_context.class_eval do
        include ::Sprockets::Helpers::RailsHelper
        include ::Sprockets::Helpers::IsolatedHelper
      end

    configure_sprockets_context
    configure_sprockets
    configure_rails
    stub_manifest
  end

  describe '#image-url' do
    context 'without anchor or query string' do
      let(:image_css) { 'image-url("my_image.png");' }
      let(:expected_image_url) { 'url(/v1/assets/my_image-abcdef123456.png);' }

      it { should eq(expected_result) }
    end

    context 'with anchor' do
      let(:image_css) { 'image-url("my_image.png?version=20171113");' }
      let(:expected_image_url) { 'url(/v1/assets/my_image-abcdef123456.png?version=20171113);' }

      it { should eq(expected_result) }
    end

    context 'with query string' do
      let(:image_css) { 'image-url("my_image.png#iefix");' }
      let(:expected_image_url) { 'url(/v1/assets/my_image-abcdef123456.png#iefix);' }

      it { should eq(expected_result) }
    end
  end

  describe '#image-path' do
    context 'without anchor or query string' do
      let(:image_css) { 'url(image-path("my_image.png"));' }
      let(:expected_image_url) { 'url("/v1/assets/my_image-abcdef123456.png");' }

      it { should eq(expected_result) }
    end

    context 'with anchor' do
      let(:image_css) { 'url(image-path("my_image.png?version=20171113"));' }
      let(:expected_image_url) { 'url("/v1/assets/my_image-abcdef123456.png?version=20171113");' }

      it { should eq(expected_result) }
    end

    context 'with query string' do
      let(:image_css) { 'url(image-path("my_image.png#iefix"));' }
      let(:expected_image_url) { 'url("/v1/assets/my_image-abcdef123456.png#iefix");' }

      it { should eq(expected_result) }
    end
  end
end
