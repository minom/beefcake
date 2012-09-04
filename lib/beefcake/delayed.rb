module Beefcake

  class Delayed
    attr_accessor :klass, :bytes, :object

    def initialize(klss, byts)
      @klass, @bytes = klss, byts
    end

    def decode
      __object__
    end

    def encode
      (@object) ? @object.encode : @bytes
    end

    def class_from_string(str)
      str.split('::').inject(Object) do |mod, class_name|
        mod.const_get(class_name)
      end
    end

    def __object__
      @object = class_from_string(@klass).decode(@bytes.dup) unless @object
      @object
    end

    alias :_inspect :inspect
    def inspect
      if @object
        @object.inspect
      else
        _inspect
      end
    end

    def respond_to?(message)
      message = message.to_sym
      [:__object__, :inspect].include?(message) ||
        __object__.respond_to?(message)
    end

    def method_missing(*a, &b)
      __object__.__send__(*a, &b)
    end

  end

end
