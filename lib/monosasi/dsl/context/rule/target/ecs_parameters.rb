class Monosasi::DSL::Context::Rule::Target::EcsParameters
  include Monosasi::DSL::TemplateHelper

  def initialize(context, &block)
    @context = context
    @result = {}
    instance_eval(&block)
  end

  attr_reader :result

  private

  def task_definition_arn(value)
    @result[:task_definition_arn] = value.to_s
  end

  def task_count(value)
    @result[:task_count] = value
  end

  def launch_type(value)
    @result[:launch_type] = value.to_s
  end

  def network_configuration(&block)
    @result[:network_configuration] = NetworkConfiguration.new(@context, &block).result
  end

  def platform_version(value)
    @result[:platform_version] = value.to_s
  end

  def group(value)
    @result[:group] = value.to_s
  end

  class NetworkConfiguration
    include Monosasi::DSL::TemplateHelper

    def initialize(context, &block)
      @context = context
      @result = {}
      instance_eval(&block)
    end

    attr_reader :result

    private

    def awsvpc_configuration(&block)
      @result[:awsvpc_configuration] = AwsvpcConfiguration.new(@context, &block).result
    end

    class AwsvpcConfiguration
      include Monosasi::DSL::TemplateHelper

      def initialize(context, &block)
        @context = context
        @result = {}
        instance_eval(&block)
      end

      attr_reader :result

      private

      def subnets(value)
        @result[:subnets] = value
      end

      def security_groups(value)
        @result[:security_groups] = value
      end

      def assign_public_ip(value)
        @result[:assign_public_ip] = value.to_s
      end
    end
  end
end
