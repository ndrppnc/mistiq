module Mistiq
	def initialize
		super
		@mode_class = self.class
		#create hash of keys and condition/consequence pairs
		@@rules = Hash.new
		#keep a counter and use it as a key for the hash
		@@count = 0
		
		#initialize the env variable
		#that will store the regex for
		#stripping out links
		@@redact_hash = Hash.new
		
		ENV['REGEX'] = ''
		
		puts "Security module has been initialized"
	end
	
	#checks every time the application runs
	#whether any of the rules is true and applies
	#the specified action
	def set_guard_on
		puts "Guard is on"
		
		current_controller = params[:controller]
		current_action = params[:action]
		
		#for each rule check
		#if the condition is true
		@@rules.each{
			|k,pair|
			if(pair[0])
				#disable the specified controller's action/view
				pair_array = pair[1].split('#')
				
				#only disable view if the current controller
				#and view are the ones that need to be disabled
				if(current_controller == pair_array[0] && current_action == pair_array[1])
					#if strip_links is true, then
					#enable link removal
					if pair[2]
						disable(pair_array[0],pair_array[1])
					else
						disable_action(pair_array[0],pair_array[1])
					end
				else
					#if strip_links is true, then
					#enable link removal
					if pair[2]
						remove_links(pair_array[0],pair_array[1])
					end
				end
			end
		}
	end
	
	#add a new rule to look out for
	def set_guard_rule(condition, consequence, strip_links=true)	
		pair = [condition,consequence,strip_links]
		@@rules["#{@@count+=1}"] = pair
		
		puts "New rule has been added: #{consequence}, strip links: #{strip_links}"
	end
	
	private
	
	#disable both the view and the action (links for the action in other views)
	def disable(controller,action)
		disable_action(controller,action)
		remove_links(controller,action)
	end

	#disable access to the action/controller by rerouting
	def disable_action(controller,action)
		redirect_to :root
	end
	
	#remove the links from the rendered HTML for
	#the specific action/controller
	def remove_links(controller,action)
		to_disable = "#{controller}##{action}"
		ENV['REGEX'] += Railtie.get_regex_hash[to_disable]+"@@@"
		puts "Removed links for action #{action}, controller #{controller}"
	end
end