class Monosasi::DSL
  class << self
    def convert(exported, options = {})
      Monosasi::DSL::Converter.convert(exported, options)
    end

    def parse(dsl, path, options = {})
      Monosasi::DSL::Context.eval(dsl, path, options).result
    end
  end # of class methods
end
