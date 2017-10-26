module ScopedWireMock
  class TemplateBuilder
    def initialize (file_name)
      @file_name=file_name
      @variables={}
    end

    def with(variable_name, variable)
      variables[variable_name]=variable
      self
    end

    def with_variables(variables)
      @variables.merge!(variables)
      self
    end

    def and_with(variable_name, variable)
      with(variable_name, variable)
      self
    end

    def and_return_it
      self
    end

    def file_name
      @file_name
    end

    def variables
      @variables
    end

  end
end