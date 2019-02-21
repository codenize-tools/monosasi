class Monosasi::DSL::Converter
  def self.convert(exported, options = {})
    self.new(exported, options).convert
  end

  def initialize(exported, options = {})
    @exported = exported
    @options = options
  end

  def convert
    output_rules(@exported)
  end

  private

  def output_rules(rule_by_name)
    rules = []

    rule_by_name.sort_by(&:first).each do |name, rule|
      rules << output_rule(name, rule)
    end

    rules.join("\n")
  end

  def output_rule(name, rule)
    body = <<-EOS
  state #{rule[:state].inspect}
    EOS

    if rule[:description]
      body += <<-EOS
  description #{rule[:description].inspect}
      EOS
    end

    if rule[:schedule_expression]
      body += <<-EOS
  schedule_expression #{rule[:schedule_expression].inspect}
      EOS
    end

    if rule[:event_pattern]
      event_pattern = rule[:event_pattern].pretty_inspect
      event_pattern.gsub!(/^/, "\s" * 4)

      body += <<-EOS
  event_pattern do
    #{event_pattern.strip}
  end
      EOS
    end

    if rule[:targets]
      body += output_targets(rule[:targets])
    end

    <<-EOS
rule #{name.inspect} do
  #{body.strip}
end
    EOS
  end

  def output_targets(targets)
    targets.map  {|id, target|
      output_target(id, target).chomp
    }.join("\n")
  end

  def output_target(id, target)
    body = <<-EOS
    arn #{target[:arn].inspect}
    EOS

    if target[:input]
      input = target[:input].pretty_inspect
      input.gsub!(/^/, "\s" * 6)

      body += <<-EOS
    input #{target[:input].inspect}
      EOS
    end

    if target[:input_path]
      body += <<-EOS
    input_path #{target[:input_path].inspect}
      EOS
    end

    if target[:input_transformer]
      body += <<-EOS
    input_transformer #{target[:input_transformer].inspect}
      EOS
    end

    if target[:ecs_parameters]
      body += output_ecs_parameters(target[:ecs_parameters])
      body += "\n"
    end

    if target[:role_arn]
      body += <<-EOS
    role_arn #{target[:role_arn].inspect}
      EOS
    end

    if target[:batch_parameters]
      body += output_batch_parameters(target[:batch_parameters])
      body += "\n"
    end

    <<-EOS.chomp
  target #{id.inspect} do
    #{body.strip}
  end
    EOS
  end

  def output_ecs_parameters(params)
    body = <<-EOS
      task_definition_arn #{params[:task_definition_arn].inspect}
    EOS

    if params[:task_count]
      body += <<-EOS
      task_count #{params[:task_count]}
      EOS
    end

    if params[:launch_type]
      body += <<-EOS
      launch_type #{params[:launch_type].inspect}
      EOS
    end

    if params[:network_configuration]
      body += output_network_configuration(params[:network_configuration])
    end

    if params[:platform_version]
      body += <<-EOS
      platform_version #{params[:platform_version].inspect}
      EOS
    end

    if params[:group]
      body += <<-EOS
      group #{params[:group].inspect}
      EOS
    end

    <<-EOS.chomp
    ecs_parameters do
      #{body.strip}
    end
    EOS
  end

  def output_batch_parameters(params)
    body = <<-EOS
      job_definition #{params[:job_definition].inspect}
      job_name #{params[:job_name].inspect}
    EOS

    <<-EOS.chomp
    batch_parameters do
      #{body.strip}
    end
    EOS
  end

  def output_network_configuration(params)
    body = ''

    if params[:awsvpc_configuration]
      body += output_awsvpc_configuration(params[:awsvpc_configuration])
      body += "\n"
    end

    <<-EOS.chomp
      network_configuration do
        #{body.strip}
      end
    EOS
  end

  def output_awsvpc_configuration(params)
    # FYI: `subnets` is required, security_groups and assign_public_ip is optional.
    # https://docs.aws.amazon.com/AmazonCloudWatchEvents/latest/APIReference/API_AwsVpcConfiguration.html
    body = <<-EOS
          subnets #{params[:subnets].inspect}
    EOS

    if params[:security_groups]
      body += <<-EOS
          security_groups #{params[:security_groups].inspect}
      EOS
    end

    if params[:assign_public_ip]
      body += <<-EOS
          assign_public_ip #{params[:assign_public_ip].inspect}
      EOS
    end

    <<-EOS.chomp
        awsvpc_configuration do
          #{body.strip}
        end
    EOS
  end
end
