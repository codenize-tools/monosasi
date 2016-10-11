class Monosasi::DSL::Context::Rule::Target
  include Monosasi::DSL::TemplateHelper

  def initialize(context, id, &block)
    @id = id
    @context = context.merge(target_id: id)
    @result = {}
    instance_eval(&block)
  end

  attr_reader :result

  private

  def arn(value)
    @result[:arn] = value.to_s
  end

  def input_path(value)
    @result[:input_path] = value.to_s
  end

  def input(value)
    @result[:input] = value.to_s
  end
end
