# Wsdl-client
require 'soap/wsdlDriver'

module WSDLClient
  class Base
    class << self
      def url=(url)
        @driver = nil
        if url.nil?
          @factory = nil
        else
          url += '?wsdl' until url.last(5).downcase == '?wsdl'
          @factory = SOAP::WSDLDriverFactory.new(url)
          @driver = @factory.create_rpc_driver

          # where put this?
          webmethods = @driver.methods - SOAP::RPC::Driver.instance_methods
          webmethods.each do |m|
            class_eval <<-ADDING_METHODS
              def self.#{m}(*args, &block)
                if args.count == 0
                  args[0] = nil
                end

                result = @driver.__send__(:#{m}, *args, &block)

                result = #{m}Result if result.respond_to?(:#{m}Result)

                methods = result.methods - SOAP::Mapping::Object.instance_methods

                if result.class == SOAP::Mapping::Object && methods.count == 2
                  result.send(methods[0].last == '=' ? methods[0].first(-1) : methods[0])
                else
                  result
                end
              end
            ADDING_METHODS
          end
        end
      end
    end
  end
end
