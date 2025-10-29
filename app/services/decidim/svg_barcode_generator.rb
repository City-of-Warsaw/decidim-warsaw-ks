# frozen_string_literal: true

require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/ascii_outputter'
require 'barby/outputter/png_outputter'
require 'barby/outputter/svg_outputter'

module Decidim
  class SvgBarcodeGenerator
    def initialize(number)
      @number = number
    end

    def call
      return '' unless @number

      Barby::Code128.new(@number.to_s).to_svg(margin: 0)
    end
  end
end
