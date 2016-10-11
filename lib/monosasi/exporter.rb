class Monosasi::Exporter
  class << self
    def export(client, options = {})
      self.new(client, options).export
    end
  end # of class methods

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  def export
    export_rules
  end

  private

  def export_rules
    result = {}
    resp = @client.list_rules

    resp.rules.each do |rule|
      rule = rule.to_h
      name = rule.delete(:name)

      if rule[:event_pattern]
        rule[:event_pattern] = JSON.parse(rule[:event_pattern])
      end

      # TODO: check target options
      targets = export_targets(name)
      rule[:targets] = targets

      result[name] = rule
    end

    result
  end

  def export_targets(rule)
    result = {}
    resp = @client.list_targets_by_rule(rule: rule)

    resp.targets.each do |target|
      target = target.to_h
      id = target.delete(:id)

      if target[:input]
        target[:input] = JSON.parse(target[:input])
      end

      result[id] = target
    end

    result
  end
end
