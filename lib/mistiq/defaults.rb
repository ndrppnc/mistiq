module Mistiq
	#disable all actions for a specific controller
	def disable_controller(controller,strip_links=true)
		Railtie.get_regex_hash.each {
			|r,p|
			set_guard_rule(true,r,strip_links) if r.match(/#{controller}.*/)
		}
	end

	#disable all 'action' operations across
	#the rails application
	def disable_action_ops(action,strip_links=true)
		Railtie.get_regex_hash.each {
			|r,p|
			set_guard_rule(true,r,strip_links) if r.match(/.*#{action}/)
		}
	end

	#disable all destroy operations across
	#the rails application
	def disable_create_ops(strip_links=true)
		Railtie.get_regex_hash.each {
			|r,p|
			set_guard_rule(true,r,strip_links) if r.match(/.*#new/) || r.match(/.*#add/)
		}
	end

	#disable all edit operations across
	#the rails application
	def disable_update_ops(strip_links=true)
		Railtie.get_regex_hash.each {
			|r,p|
			set_guard_rule(true,r,strip_links) if r.match(/.*#edit/) || r.match(/.*#update/)
			puts p
		}
	end

	#disable all destroy operations across
	#the rails application
	def disable_destroy_ops(strip_links=true)
		Railtie.get_regex_hash.each {
			|r,p|
			set_guard_rule(true,r,strip_links) if r.match(/.*#destroy/) || r.match(/.*#delete/) || r.match(/.*#remove/) 
		}
	end
end