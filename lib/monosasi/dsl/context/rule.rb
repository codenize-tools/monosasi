class Monosasi::DSL::Context::Rule
  include Monosasi::DSL::TemplateHelper

  def initialize(context, name, &block)
    @name = name
    @context = context.merge(rule_name: name)
    @result = {:targets => {}}
    instance_eval(&block)
  end

  attr_reader :result

  private

  def arn(value)
    @result[:arn] = value.to_s
  end

  def state(value)
    @result[:state] = value.to_s
  end

  def schedule_expression(value)
    @result[:schedule_expression] = value.to_s
  end

  def event_pattern
    value = yield

    unless value.is_a?(Hash)
      raise TypeError, "wrong expand_path type (given #{value.inspect}:#{value.class}, expected Hash)"
    end

    @result[:event_pattern] = value
  end

  def target(id, &block)
    id = id.to_s
    @result[id] = Monosasi::DSL::Context::Rule::Target.new(@context, id, &block).result
  end
end
