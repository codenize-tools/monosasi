class Monosasi::Client
  def initialize(options = {})
    @options = options
    @client = @options[:client] || Aws::CloudWatchEvents::Client.new
  end

  def export
    Monosasi::Exporter.export(@client)
  end

  def apply(file)
    # TODO:
  end
end
