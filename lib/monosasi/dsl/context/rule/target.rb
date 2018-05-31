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

  def role_arn(value)
    @result[:role_arn] = value.to_s
  end

  def ecs_parameters(*values)
    @result[:ecs_parameters] = Hash(*values)
  end

  def batch_parameters(*values)
    @result[:batch_parameters] = Hash(*values)
  end
end
