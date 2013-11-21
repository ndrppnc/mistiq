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
				inspector = RoutesInspector.new(routes)
				routes = inspector.get_routes
				
				routes.each {
					|r|

					reqs = r[:reqs].split('#')

					controller = reqs[0]
					action = reqs[1]
					
					route = r[:path]
					verb = r[:verb]

					#get regex-ed route
					regex_len = r[:regexp].length
					regex = r[:regexp].slice(1..regex_len-2)

					#if action#controller's data method is not GET and not POST
					if verb != "GET" && verb != "POST" && verb != ""
						method_regex = "data-method=(\"|')#{verb.downcase}(\"|')";
						pattern = "<a.*#{method_regex}.*href=(\"|')#{regex}(\"|').*>.*<\/a>"

						#also check if method_regex occurs after the href attribute
						pattern = pattern+"@@@<a.*href=(\"|')#{regex}(\"|').*#{method_regex}.*>.*<\/a>"
					elsif verb == "GET"
						#if action#controller's data method is GET
						#pattern = "<a(.*href=(\"|')#{pattern}(\"|'))(?!.*data\-method)[^<]*<\/a>"
						pattern = "<a(?!.*data\-method)(.*href=(\"|')#{regex}(\"|'))[^<]*<\/a>"
					end
					
					if verb == "GET" || (verb != "POST" && verb != "")
						@LINK_REGEX_HASH["#{controller}##{action}"] = pattern
					end
				}
				
				puts "Link REGEX hash has been computed. #{@LINK_REGEX_HASH.size} routes were hashed."
			end
		end

		def get_regex_hash
			@LINK_REGEX_HASH
		end
	end

	class RouteWrapper < SimpleDelegator
		def endpoint
			rack_app ? rack_app.inspect : "#{controller}##{action}"
		end

	    def constraints
	        requirements.except(:controller, :action)
	    end

	    def rack_app(app = self.app)
			@rack_app ||= begin
				class_name = app.class.name.to_s
				if class_name == "ActionDispatch::Routing::Mapper::Constraints"
					rack_app(app.app)
	        	elsif ActionDispatch::Routing::Redirect === app || class_name !~ /^ActionDispatch::Routing/
	            	app
	          	end
	        end
	    end

		def verb
			super.source.gsub(/[$^]/, '')
		end

		def path
			super.spec.to_s
		end

		def name
			super.to_s
		end

		def regexp
			__getobj__.path.to_regexp
		end

		def json_regexp
			str = regexp.inspect.
					sub('\\A' , '^').
					sub('\\Z' , '$').
					sub('\\z' , '$').
					sub(/^\// , '').
					sub(/\/[a-z]*$/ , '').
					gsub(/\(\?#.+\)/ , '').
					gsub(/\(\?-\w+:/ , '(').
					gsub(/\s/ , '')
			Regexp.new(str).source
		end

		def reqs
			@reqs ||= begin
				reqs = endpoint
				reqs += " #{constraints.to_s}" unless constraints.empty?
				reqs
			end
		end

		def controller
			requirements[:controller] || ':controller'
		end

		def action
			requirements[:action] || ':action'
		end

		def internal?
			controller.to_s =~ %r{\Arails/(info|welcome)} || path =~ %r{\A#{Rails.application.config.assets.prefix}}
		end

		def engine?
			rack_app && rack_app.respond_to?(:routes)
		end
    end

    class RoutesInspector
		def initialize(routes)
			@engines = {}
			@routes = routes
		end

		def get_routes
			routes_to_display = filter_routes(nil)
			routes = collect_routes(routes_to_display)
			return routes
		end

		private

		def filter_routes(filter)
			if filter
				@routes.select { |route| route.defaults[:controller] == filter }
			else
				@routes
			end
		end

      	def collect_routes(routes)
			routes.collect do |route|
			  RouteWrapper.new(route)
			end.reject do |route|
			  route.internal?
			end.collect do |route|
			  collect_engine_routes(route)

			  { name:   route.name,
			    verb:   route.verb,
			    path:   route.path,
			    reqs:   route.reqs,
			    regexp: route.json_regexp }
			end
      	end

      	def collect_engine_routes(route)
			name = route.endpoint
			return unless route.engine?
			return if @engines[name]

			routes = route.rack_app.routes
			if routes.is_a?(ActionDispatch::Routing::RouteSet)
				@engines[name] = collect_routes(routes.routes)
			end
      	end
    end
end