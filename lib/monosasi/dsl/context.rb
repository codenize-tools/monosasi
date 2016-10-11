class Monosasi::DSL::Context
  include Monosasi::DSL::TemplateHelper

  def self.eval(dsl, path, options = {})
    self.new(path, options) do
      eval(dsl, binding, path)
    end
  end

  def result
    @result.sort_array!
  end

  def initialize(path, options = {}, &block)
    @path = path
    @options = options
    @result = {}

    @context = Hashie::Mash.new(
      :path => path,
      :options => options,
      :templates => {}
    )

    instance_eval(&block)
  end

  def template(name, &block)
    @context.templates[name.to_s] = block
  end

  private

  def require(file)
    rule_file = (file =~ %r|\A/|) ? file : File.expand_path(File.join(File.dirname(@path), file))

    if File.exist?(rule_file)
      instance_eval(File.read(rule_file), rule_file)
    elsif File.exist?(rule_file + '.rb')
      instance_eval(File.read(rule_file + '.rb'), rule_file + '.rb')
    else
      Kernel.require(file)
    end
  end

  def rule(name, &block)
    name = name.to_s

    if @result[name]
      raise "Rule `#{name}` is already defined"
    end

    @result[name] = Monosasi::DSL::Context::Rule.new(@context, name, &block).result
  end
end
