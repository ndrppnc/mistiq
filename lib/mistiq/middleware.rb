module Mistiq
	class Railtie < Rails::Railtie
		initializer "mistiq.configure_rails_initialization" do |app|
			app.config.middleware.use Middleware
		end
	end

  	class Middleware 
		def initialize(app)  
			@app = app
		end  

		def call(env)
			status, headers, response = @app.call(env)

			#if the current file is an HTML document
			if headers != nil && headers["Content-Type"] != nil && (headers["Content-Type"].include? "text/html")		
				if ENV['REGEX'] != nil
					regex = ENV['REGEX'].split("@@@")
					body = response.body
					
					regex.each {
						|r|			
						temp = body.gsub(/#{r}/,"")
						if temp != nil
							body = temp
						end
					}

					#rebuild response
					response = Rack::Response.new(body,status,headers)
					response.finish
				else
					[status, headers, response]
				end
			else
				[status, headers, response]
			end
		end  
	end
end