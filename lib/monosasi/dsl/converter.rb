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

    if target[:ecs_parameters]
      body += <<-EOS
    ecs_parameters #{target[:ecs_parameters].inspect}
      EOS
    end

    if target[:role_arn]
      body += <<-EOS
    role_arn #{target[:role_arn].inspect}
      EOS
    end

    if target[:batch_parameters]
      body += <<-EOS
    batch_parameters #{target[:batch_parameters].inspect}
      EOS
    end

    <<-EOS.chomp
  target #{id.inspect} do
    #{body.strip}
  end
    EOS
  end
end
