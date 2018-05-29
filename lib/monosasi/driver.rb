class Monosasi::Driver
  include Monosasi::Logger::Helper
  include Monosasi::Utils::Diff

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  def create_rule(rule_name, rule)
    log(:info, "Create Rule `#{rule_name}`", color: :cyan)

    unless @options[:dry_run]
      put_rule(rule_name, rule)
    end
  end

  def delete_rule(rule_name, rule)
    log(:info, "Delete Rule `#{rule_name}`", color: :red)

    unless @options[:dry_run]
      targets = rule[:targets]

      unless targets.empty?
        @client.remove_targets(:rule => rule_name, :ids => targets.keys)
      end

      @client.delete_rule(:name => rule_name)
    end
  end

  def update_rule(rule_name, rule, old_rule)
    log(:info, "Update Rule `#{rule_name}`", color: :green)
    log(:info, diff(old_rule, rule, color: @options[:color]), color: false)

    unless @options[:dry_run]
      put_rule(rule_name, rule)
    end
  end

  def create_target(rule_name, target_id, target)
    log(:info, "Create Rule `#{rule_name}` > Target `#{target_id}`", color: :cyan)

    unless @options[:dry_run]
      put_target(rule_name, target_id, target)
    end
  end

  def delete_target(rule_name, target_id)
    log(:info, "Delete Rule `#{rule_name}` > Target `#{target_id}`", color: :red)

    unless @options[:dry_run]
      @client.remove_targets(:rule => rule_name, :ids => [target_id])
    end
  end

  def update_target(rule_name, target_id, target, old_target)
    log(:info, "Update Rule `#{rule_name}` > Target `#{target_id}`", color: :green)
    log(:info, diff(old_target, target, color: @options[:color]), color: false)

    unless @options[:dry_run]
      put_target(rule_name, target_id, target)
    end
  end

  private

  def put_rule(rule_name, rule)
      params = {
        :name => rule_name,
        :state => rule[:state],
        :role_arn => rule[:role_arn],
      }

      if rule[:description]
        params[:description] = rule[:description]
      end

      if rule[:schedule_expression]
        params[:schedule_expression] = rule[:schedule_expression]
      end

      if rule[:event_pattern]
        params[:event_pattern] = JSON.dump(rule[:event_pattern])
      end

      @client.put_rule(params)
  end

  def put_target(rule_name, target_id, target)
    params_target = {
      :id => target_id,
      :arn => target[:arn],
    }

    if target[:input]
      params_target[:input] = target[:input]
    end

    if target[:input_path]
      params_target[:input_path] = target[:input_path]
    end

    if target[:role_arn]
      params_target[:role_arn] = target[:role_arn]
    end

    if target[:ecs_parameters]
      params_target[:ecs_parameters] = target[:ecs_parameters]
    end

    if target[:batch_parameters]
      params_target[:batch_parameters] = target[:batch_parameters]
    end

    params = {
      :rule => rule_name,
      :targets => [params_target],
    }

    @client.put_targets(params)
  end
end
