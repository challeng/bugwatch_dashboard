require 'ruby_parser'
require 'sexp_processor'

module Bugwatch

  class MethodParser < SexpProcessor

    attr_reader :parser, :klasses

    class MethodFound < Exception; end

    def initialize(line_range)
      super()
      @line_range = line_range
      @klasses = Hash.new {|h, k| h[k] = []}
      @current_class = []
      self.auto_shift_type = true
    end

    def self.find(code, line_range)
      method_parser = new(line_range)
      ast = RubyParser.new.process(code)
      method_parser.process ast
      method_parser.klasses
    end

    def process_class(exp)
      line_range = exp.line..exp.last.line
      class_name = get_class_name(exp.shift)
      within_class(class_name, line_range) do
        process(exp.shift)
        process(exp.shift)
      end
      s()
    end

    alias_method :process_module, :process_class

    def process_defn(exp)
      first_line_of_method = exp.line
      name = exp.shift
      @klasses[current_class].push name.to_s if within_target?(first_line_of_method..exp.last.line)
      Sexp.new(name, process(exp.shift), process(exp.shift), process(exp.shift))
    end

    def within_class(class_name, line_range, &block)
      @current_class.push class_name
      methods_before_process = @klasses[current_class].count
      block.call
      if (methods_before_process == @klasses[current_class].count) && within_target?(line_range)
        @klasses[current_class].push nil
      end
      @current_class.shift
    end

    def within_target?(range)
      @line_range.any? {|num| range.cover? num}
    end

    def current_class
      @current_class.join("::")
    end

    def get_class_name(exp, namespace=[])
      if exp.is_a?(Sexp) && exp.first.is_a?(Sexp)
        get_class_name(exp.first, namespace + [exp.last])
      elsif exp.is_a?(Sexp) && exp[1].is_a?(Sexp)
        get_class_name(exp[1], namespace + [exp.last])
      else
        ([Array(exp).last] + namespace.reverse).join("::")
      end
    end

  end

end
