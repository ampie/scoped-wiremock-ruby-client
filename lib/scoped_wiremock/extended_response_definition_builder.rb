require_relative '../wiremock/response_definition_builder'
module ScopedWireMock
  class ExtendedResponseDefinitionBuilder < WireMock::ResponseDefinitionBuilder
    def initialize
      super
      @intercepted_from_source=false
    end
    def intercepted_from_source
      @intercepted_from_source=true
      self
    end
    def build
      result = super
      result['interceptFromSource']=@intercepted_from_source
      result
    end
  end
end