class Monosasi::Utils
  module TargetMatcher
    def target?(name)
      if @options[:target]
        @options[:target] =~ name
      else
        true
      end
    end
  end
end
