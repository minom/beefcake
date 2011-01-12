require 'beefcake/varint'
require 'beefcake/lendel'
require 'beefcake/errors'

module Beefcake
  module Encode
    extend self

    ##
    # Encodes an object `obj` to `w` according to fields `flds` after checking
    # with `validate!` that it's safe to do so.
    #
    # `flds` Array
    #     [[:required, :a, :int32, 1], [:optional, :tag, :string, 2]]
    #
    # `obj` Must respond to `[]`
    def encode(w, obj, flds)
      validate!(obj, flds)
      flds.each do |_, name, *rest|
        encode!(w, obj[name], *rest)
      end
      w
    end

    ##
    # Encodes a single field to `w`
    # `w`    ~`<<`
    # `val`  Object
    # `type` Symbol
    # `fn`   Integer
    def encode!(w, val, type, fn)
      return if val.nil?

      case type
      when :int32, :uint32, :int64, :uint64, :bool, :enum
        encode_info(w, fn, 0)
        encode_varint(w, val)
      when :sint32
        encode_info(w, fn, 0)
        encode_varint(w, (val << 1) ^ (val >> 31))
      #when :sint64
      #when :sfixed64
      #when :fixed64, :double
      when :string, :bytes
        encode_info(w, fn, 2)
        encode_lendel(w, val)
      else
        if val.respond_to?(:encode)
          encode_info(w, fn, 2)
          encode_lendel(w, val.encode(""))
        else
          raise UnknownType, type
        end
      end

      w
    end

    def encode_info(w, fn, wire)
      w << ((fn << 3) | wire)
    end

    def encode_varint(w, v)
      while v > 127
        w << (0x80 | (v&0x7F))
        v = v>>7
      end
      w << v
    end

    def encode_lendel(w, v)
      Varint.encode(w, v.length)
      w << v
    end

    ##
    # Validates the existance of required fields. If any field is required but
    # does not contain a value in `obj` this will raise a MissingField error.
    def validate!(obj, flds)
      flds.each do |rule, name|
        if rule == :required && obj[name].nil?
          raise MissingField, name
        end
      end
    end
  end
end