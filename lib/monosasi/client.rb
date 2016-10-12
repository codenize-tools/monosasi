class Monosasi::Client
  include Monosasi::Utils::TargetMatcher

  def initialize(options = {})
    @options = options
    @client = @options[:client] || Aws::CloudWatchEvents::Client.new
    @driver = Monosasi::Driver.new(@client, options)
    @exporter = Monosasi::Exporter.new(@client, @options)
  end

  def export
    @exporter.export
  end

  def apply(file)
    walk(file)
  end

  private

  def walk(file)
    expected = load_file(file)
    actual =  @exporter.export

    updated = walk_rules(expected, actual)

    if @options[:dry_run]
      false
    else
      updated
    end
  end

  def walk_rules(expected, actual)
    updated = false

    expected.each do |rule_name, expected_rule|
      next unless target?(rule_name)

      actual_rule = actual.delete(rule_name)

      unless actual_rule
        @driver.create_rule(rule_name, expected_rule)
        updated = true
        actual_rule = expected_rule.merge(:targets => {})
      end

      updated = walk_rule(rule_name, expected_rule, actual_rule) || updated
    end

    actual.each do |rule_name, actual_rule|
      next unless target?(rule_name)

      @driver.delete_rule(rule_name, actual_rule)
      updated = true
    end

    updated
  end

  def walk_rule(rule_name, expected, actual)
    updated = false

    expected_without_targets = expected.dup
    expected_targets = expected_without_targets.delete(:targets)

    actual_without_targets = actual.dup
    actual_targets = actual_without_targets.delete(:targets)

    if expected_without_targets != actual_without_targets
      @driver.update_rule(rule_name, expected_without_targets, actual_without_targets)
      updated = true
    end

    walk_targets(rule_name, expected_targets, actual_targets) || updated
  end

  def walk_targets(rule_name, expected, actual)
    updated = false

    expected.each do |target_id, expected_target|
      actual_target = actual.delete(target_id)

      if not actual_target
        @driver.create_target(rule_name, target_id, expected_target)
        updated = true
      elsif expected_target != actual_target
        @driver.update_target(rule_name, target_id, expected_target, actual_target)
        updated = true
      end
    end

    actual.each do |target_id, actual_target|
      @driver.delete_target(rule_name, target_id)
      updated = true
    end

    updated
  end

  def load_file(file)
    if file.kind_of?(String)
      open(file) do |f|
        Monosasi::DSL.parse(f.read, file)
      end
    elsif file.respond_to?(:read)
      Monosasi::DSL.parse(file.read, file.path)
    else
      raise TypeError, "can't convert #{file} into File"
    end
  end
end
