module Monosasi::Ext
  module HashExt
    def sort_array!
      keys.each do |key|
        value = self[key]
        self[key] = sort_array0(value)
      end

      self
    end

    private

    def sort_array0(value)
      case value
      when Hash
        new_value = {}

        value.each do |k, v|
          new_value[k] = sort_array0(v)
        end

        new_value
      when Array
        value.map {|v| sort_array0(v) }.sort_by(&:to_s)
      else
        value
      end
    end
  end

  def pretty_print(q)
    q.group(1, '{', '}') {
      q.seplist(self.sort_by {|k, _| k.to_s } , nil, :each) {|k, v|
        q.group {
          q.pp k
          q.text '=>'
          q.group(1) {
            q.breakable ''
            q.pp v
          }
        }
      }
    }
  end
end

Hash.send(:include, Monosasi::Ext::HashExt)
