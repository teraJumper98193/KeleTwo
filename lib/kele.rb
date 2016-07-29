require "httparty"
require "kele/errors"
require "json"
require "kele/roadmap"



class Kele
    include HTTParty
    include Roadmap
    def initialize(email, password)
        response = self.class.post(base_api_endpoint("sessions"), body: { "email": email, "password": password })
        @auth_token = response["auth_token"]
        raise InvalidStudentCodeError.new() if response.code == 401

    end
end
