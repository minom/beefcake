module Beefcake

  class Delayed
    attr_accessor :klass, :bytes
    
    def initialize(klss, byts)
      self.klass, self.bytes = klss, byts
    end
    
    def decode
      Object.const_get(self.klass).decode(self.bytes)
    end
    
    def encode
      self.bytes
    end
  end
  
end