mistiq
======

<b>Setup:</b>

1. Install Mistiq gem
2. In your application controller:

    Include the module using:
    
        include Mistiq
    
    Add rules that get triggered when your anomaly detector returns true. If it is, it will disable the <b>action</b> for the <b>controller</b>:
    
        before_filter { |c| c.set_guard_rule(EVAL_FUNCTION, 'controller#action'[, strip_links]) }
    
    <b>strip_links</b> is an optional boolean variable that determines whether the links for that <b>action#controller</b> should be stripped off or not. <b>strip_links</b> is <b>true</b> by default.
    
    Last, after you defined the rules, add the following line to check them before your application gets rendered:
    
        before_filter :set_guard_on
