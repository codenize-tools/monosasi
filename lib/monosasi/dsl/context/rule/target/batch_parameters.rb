class Monosasi::DSL::Context::Rule::Target::BatchParameters
  include Monosasi::DSL::TemplateHelper

  def initialize(context, &block)
    @context = context
    @result = {}
    instance_eval(&block)
  end

  attr_reader :result

  private

  def job_definition(value)
    @result[:job_definition] = value.to_s
  end

  def job_name(value)
    @result[:job_name] = value.to_s
  end
end
