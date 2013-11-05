module Mistiq
	class Railtie < Rails::Railtie
		initializer "mistiq.configure_rails_initialization" do |app|
			#computes a hash of regex-ed routes, later used
			#to redact links in the views
			Rails.application.config.after_initialize do
				@LINK_REGEX_HASH = Hash.new

				#pre-load routes
				Rails.application.reload_routes!
				
				#get routes
				routes = Rails.application.routes.routes
				
				routes.each {
					|r|
					controller = r.defaults[:controller]
					action = r.defaults[:action]
					
					route = r.path.spec.to_s
					
					#removes (.:format)
					if route.match("(.:format)")
						pattern = route.sub("(.:format)","")
					else
						pattern = route
					end
					
					#if there are any parameters in
					#the route use regex to ignore them
					if pattern.match(/(:.*\/)/)
						pattern.gsub!(/(:.*\/)/,".*/")
					end
					
					#if there is a parameter at the end
					if pattern.match(/(:.*)/)
						pattern.gsub!(/(:.*)/,"[^\/\"]*")
					end
					
					if action == "destroy"
						destroy_regex = "data-method=(\"|')delete(\"|')";
						pattern = "<a.*#{destroy_regex}.*href=(\"|')#{pattern}(\"|').*>.*<\/a>"
						#also check if destroy_regex occurs after the href attribute
						pattern = pattern+"@@@<a.*href=(\"|')#{pattern}(\"|').*#{destroy_regex}.*>.*<\/a>"
					else
						pattern = "<a.*href=(\"|')#{pattern}(\"|').*>.*<\/a>"
					end
					
					#espace / characters
					pattern.gsub!(/\//,"\\/")
					
					@LINK_REGEX_HASH["#{controller}##{action}"] = pattern
				}
				
				puts "Link REGEX hash has been computed"
			end
		end

		def get_regex_hash
			@LINK_REGEX_HASH
		end
	end
end