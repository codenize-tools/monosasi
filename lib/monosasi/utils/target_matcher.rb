class Monosasi::Utils
  module TargetMatcher
    def target?(name)
      case
      when @options[:include]
        @options.fetch(:include) =~ name
      when @options[:target]
        @options.fetch(:target) =~ name
      when @options[:exclude]
        @options.fetch(:exclude) !~ name
      else
        true
      end
    end
  end
end
