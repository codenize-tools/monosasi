class Monosasi::Exporter
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
    resp = @client.list_rules

    Parallel.each(resp.rules, in_threads: CONCURRENCY) do |rule|
      rule = rule.to_h
      name = rule.delete(:name)

      if rule[:event_pattern]
        rule[:event_pattern] = JSON.parse(rule[:event_pattern])
      end

      # TODO: check target options
      targets = export_targets(name)
      rule[:targets] = targets

      rule_by_name[name] = rule
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
