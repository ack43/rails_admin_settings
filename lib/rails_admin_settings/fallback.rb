module RailsAdminSettings
  # we are inheriting from BasicObject so we don't get a bunch of methods from
  # Kernel or Object
  class Fallback < BasicObject

    DELEGATE = [:puts, :p, :block_given?].freeze

    def initialize(ns, fb)
      @ns = ns
      @fb = fb
    end

    def inspect
      "#<RailsAdminSettings::Fallback ns: #{@ns.inspect}, fb: #{@fb.inspect}>".freeze
    end

    def method_missing(name, *args, &block)
      return ::Kernel.send(name, *args, &block) if DELEGATE.include?(name)

      @ns.ns_mutex.synchronize do
        @ns.fallback = @fb
        @ns.__send__(name, *args, &block)
      end
    end
  end
end
