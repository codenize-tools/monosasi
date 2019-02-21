class Monosasi::DSL::Context::Rule::Target
  include Monosasi::DSL::TemplateHelper
  include Monosasi::Logger::Helper # TODO: remove this line when log() would not been called

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

  def input_transformer(value)
    @result[:input_transformer] = value.to_h
  end

  def role_arn(value)
    @result[:role_arn] = value.to_s
  end

  def ecs_parameters(*values, &block)
    unless values.nil?
      log(:warn, "`ecs_parameter(Hash)` will no longer be available. use ecs_parameter(block)", color: :yellow)
      @result[:ecs_parameters] = Hash(*values)
    else
      @result[:ecs_parameters] = Monosasi::DSL::Context::Rule::Target::EcsParameters.new(@context, &block).result
    end
  end

  def batch_parameters(*values, &block)
    unless values.nil?
      log(:warn, "`batch_parameter(Hash)` will no longer be available. use batch_parameter(block)", color: :yellow)
      @result[:batch_parameters] = Hash(*values)
    else
      @result[:batch_parameters] = Monosasi::DSL::Context::Rule::Target::BatchParameters.new(@context, &block).result
    end
  end
end
