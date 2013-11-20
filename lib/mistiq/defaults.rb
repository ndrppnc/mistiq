module Mistiq
	#disable all 'action' operations across
	#the rails application
	def disable_action_ops(action)
		Railtie.get_regex_hash.each {
			|r,p|
			set_guard_rule(true,r) if r.match(/.*#{action}/)
		}
	end

	#disable all destroy operations across
	#the rails application
	def disable_create_ops()
		Railtie.get_regex_hash.each {
			|r,p|
			set_guard_rule(true,r) if r.match(/.*#new/) || r.match(/.*#add/)
		}
	end

	#disable all edit operations across
	#the rails application
	def disable_update_ops()
		Railtie.get_regex_hash.each {
			|r,p|
			set_guard_rule(true,r) if r.match(/.*#edit/) || r.match(/.*#update/)
			puts p
		}
	end

	#disable all destroy operations across
	#the rails application
	def disable_destroy_ops()
		Railtie.get_regex_hash.each {
			|r,p|
			set_guard_rule(true,r) if r.match(/.*#destroy/) || r.match(/.*#delete/) || r.match(/.*#remove/) 
		}
	end
end