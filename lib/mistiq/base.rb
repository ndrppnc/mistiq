module Mistiq
	def self.included(base)
		#base.send(:before_filter, :set_guard_on)
	end
	
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
					disable(pair_array[0],pair_array[1],pair[2])
				else
					disable_action(pair_array[0],pair_array[1])
				end
			end
		}
	end
	
	#add a new rule to look out for
	#takes in an optional parameter for the view to
	#be rendered in place of the current one
	def set_guard_rule(condition, consequence, alternate_view='denied')	
		pair = [condition,consequence,alternate_view]
		@@rules["#{@@count+=1}"] = pair
		
		puts "New rule has been added: #{consequence}, render #{alternate_view}"
	end
	
	private
	
	#disable both the view and the action (links for the action in other views)
	def disable(controller,action,alternate_view)
		disable_view(controller,action,alternate_view)
		disable_action(controller,action)
	end
	
	#disable the view when url is requested
	def disable_view(controller,action,alternate_view)
		render :text => action, :layout => alternate_view
		puts "Disabled view for action #{action}, controller #{controller}"
	end
	
	#disable the specified action in the controller
	#by removing the links from the rendered HTML and by
	#disabling the action in the model
	def disable_action(controller,action)
		to_disable = "#{controller}##{action}"
		ENV['REGEX'] += Railtie.get_regex_hash[to_disable]+"@@@"
		puts "Removed links for action #{action}, controller #{controller}"
		#TODO: should also disable ACTUAL action in the model
	end
end