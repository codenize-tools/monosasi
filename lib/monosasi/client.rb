class Monosasi::Client
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

    expected.each do |rule_name,  expected_rule|
      # TODO: check target options

      actual_rule = actual.delete(rule_name)

      unless actual_rule
        # TODO: create_rule
        updated = true
      end

      updated = walk_rule(rule_name, expected_rule, actual_rule) || updated
    end

    actual.each do |rule_name, actual_rule|
      # TODO: check target options
      # TODO: delete_rule
      updated = true
    end

    updated
  end

  def walk_rule(rule_name, expected, actual)
    # TODO:
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
