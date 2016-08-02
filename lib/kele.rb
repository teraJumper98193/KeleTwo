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

    def get_me
        response = self.class.get(base_api_endpoint("users/me"), headers: { "authorization" => @auth_token })
        @user_data = JSON.parse(response.body)
    end

    def get_mentor_availability(mentor_id)
        response = self.class.get(base_api_endpoint("mentors/#{mentor_id}/student_availability"), headers: { "authorization" => @auth_token })
        @mentor_availability = JSON.parse(response.body)
    end
    

    def get_messages(*page)
       if page.empty?
           response = self.class.get(base_api_endpoint("message_threads"), headers: { "authorization" => @auth_token })
           @messages = (1..(response["count"]/10 + 1)).map do |i|
               self.class.get(base_api_endpoint("message_threads?page=#{i}"), headers: { "authorization" => @auth_token })

           end
              puts @messages

       else
           response = self.class.get(base_api_endpoint("message_threads?page=#{page.join.to_i}"), headers: { "authorization" => @auth_token })
           @messages = JSON.parse(response.body)

       end
   end

   def create_message(user_id, recipient_id, token, subject, stripped)
       message_data = {body: {user_id: user_id, recipient_id: recipient_id, token: nil, subject: subject, stripped: stripped}, headers: { "authorization" => @auth_token }}
       self.class.post(base_api_endpoint("messages"), message_data)
   end



   private

    def base_api_endpoint(end_point)
        "https://www.bloc.io/api/v1/#{end_point}"
    end

end
