# frozen_string_literal: true

# This service confirms the required parameters are present or not
class MissingParameterHandler
  # Just a simple constant error for scope of test, we can iterate and check
  # which param is not present and create error dynamically and fill errors array
  PARAM_MISSING = 'All required parameters not present'

  def initialize(incoming_parameters, required_parameters)
    @received_params = incoming_parameters
    @required_params = required_parameters
  end

  def call
    if required_attributes_present?
      build_response
    else
      build_response(false, PARAM_MISSING)
    end
  end

  private

  def required_attributes_present?
    @required_params.all? { |param| @received_params[param] }
  end

  def build_response(success = true, errors = [])
    {
      success: success,
      errors: errors
    }
  end
end
