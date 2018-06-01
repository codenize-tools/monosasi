class Monosasi::Exporter
  include Monosasi::Utils::TargetMatcher

  CONCURRENCY = 8

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  def export
    export_rules.sort_array!
  end

  private

  def export_rules
    rule_by_name = {}
    next_token = nil
    loop do
      resp = @client.list_rules(next_token: next_token)

      Parallel.each(resp.rules, in_threads: CONCURRENCY) do |rule|
        rule = rule.to_h
        rule.delete(:arn)
        rule_name = rule.delete(:name)

        next unless target?(rule_name)

        if rule[:event_pattern]
          rule[:event_pattern] = JSON.parse(rule[:event_pattern])
        end

        targets = export_targets(rule_name)
        rule[:targets] = targets

        rule_by_name[rule_name] = rule
      end

      break if (next_token = resp.next_token).nil?
    end

    rule_by_name
  end

  def export_targets(rule_name)
    target_by_id = {}
    resp = @client.list_targets_by_rule(rule: rule_name)

    resp.targets.each do |target|
      target = target.to_h
      id = target.delete(:id)
      target_by_id[id] = target
    end

    target_by_id
  end
end
