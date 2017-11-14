# frozen_string_literal: true

require 'active_support/core_ext/module/aliasing'
require 'sass/rails'
require 'sass/rails/query_string_and_anchor_fix/version'

module Sass
  module Rails
    # rubocop:disable Metrics/BlockLength
    Helpers.class_eval do
      # rubocop:enable Metrics/BlockLength

      # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      def preserving_query_strings_and_anchors(asset, closing_chars)
        # rubocop:enable Metrics/AbcSize,Metrics/MethodLength
        split_point = [asset.value.index('#'), asset.value.index('?')].compact.min
        if split_point
          suffix = asset.value[split_point..-1]
          asset = asset.class.new(
            asset.value[0, split_point],
            asset.type,
            asset.instance_variable_get('@deprecated_interp_equivalent')
          )
        end
        asset = yield(asset)
        if split_point
          new_value =
            if closing_chars.zero?
              asset.value + suffix
            else
              asset.value[0..(-closing_chars - 1)] + suffix + asset.value[-closing_chars..-1]
            end
          asset = asset.class.new(
            new_value,
            asset.type,
            asset.instance_variable_get('@deprecated_interp_equivalent')
          )
        end
        asset
      end

      %i[image video audio javascript stylesheet font].each do |asset_class|
        # rubocop:disable Style/CommentedKeyword
        class_eval %{
          def #{asset_class}_path_with_correct_handling_of_query_strings_and_anchors(asset)
            preserving_query_strings_and_anchors(asset, 0) do |asset_without_query_string|
              #{asset_class}_path_without_correct_handling_of_query_strings_and_anchors(
                asset_without_query_string
              )
            end
          end
          def #{asset_class}_url_with_correct_handling_of_query_strings_and_anchors(asset)
            preserving_query_strings_and_anchors(asset, 1) do |asset_without_query_string|
              #{asset_class}_url_without_correct_handling_of_query_strings_and_anchors(
                asset_without_query_string
              )
            end
          end
        }, __FILE__, __LINE__ - 10
        # rubocop:enable Style/CommentedKeyword
        alias_method_chain :"#{asset_class}_path", :correct_handling_of_query_strings_and_anchors
        alias_method_chain :"#{asset_class}_url", :correct_handling_of_query_strings_and_anchors
      end
    end
  end
end
