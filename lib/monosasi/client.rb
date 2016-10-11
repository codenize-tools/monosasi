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
    # TODO:
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
