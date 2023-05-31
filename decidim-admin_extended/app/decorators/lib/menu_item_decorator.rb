# frozen_string_literal: true

Decidim::MenuItem.class_eval do

  def initialize(label, url, options = {})
    @label = label
    @url = url
    @position = options[:position] || Float::INFINITY
    @if = options[:if]
    @active = options[:active]
    @icon_name = options[:icon_name]
    @original_label = options[:original_label]

    @visible = options.key?(:visible) ? options[:visible] : true
  end

  attr_reader :original_label, :visible

  def visible?
    return true if (@if.nil? || @if) && @visible

    false
  end
end
