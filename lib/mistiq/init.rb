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

				#for each routes.collect |route|
				# => route 
				
				routes.each {
					|r|
					controller = r.defaults[:controller]
					action = r.defaults[:action]
					
					route = r.path.spec.to_s
					verb = r.verb.source.to_s.gsub(/\^|\$/,"")

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

					#if action#controller's data method is not GET and not POST
					if verb != "GET" && verb != "POST" && verb != ""
						method_regex = "data-method=(\"|')#{verb.downcase}(\"|')";
						pattern = "<a.*#{method_regex}.*href=(\"|')#{pattern}(\"|').*>.*<\/a>"

						#also check if method_regex occurs after the href attribute
						pattern = pattern+"@@@<a.*href=(\"|')#{method_regex}(\"|').*#{method_regex}.*>.*<\/a>"
					elsif verb == "GET"
						#if action#controller's data method is GET
						pattern = "<a[^>]*href=(\"|')#{pattern}(\"|')[^>]*(?!.*data\-method)[^<]*<\/a>"
					end
					
					#escape / characters
					pattern.gsub!(/\//,"\\/")

					@LINK_REGEX_HASH["#{controller}##{action}"] = pattern
				}
				
				puts "Link REGEX hash has been computed. #{@LINK_REGEX_HASH.size} routes found."
			end
		end

		def get_regex_hash
			@LINK_REGEX_HASH
		end
	end
end