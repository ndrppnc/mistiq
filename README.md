mistiq
======

<b>Setup:</b>

1. Install Mistiq gem
2. In your application controller:

    Include the module using:
    
        include Mistiq
    
    Add rules that get triggered when your anomaly detector returns true. If it is, it will disable the <b>action</b> for the <b>controller</b>:
    
        before_filter { |c| c.set_guard_rule(ANOMALY_DETECTOR_EVAL_FUNCTION,'controller#action') }
    
    Last, after you defined the rules, add the following line to check them before your application gets rendered:
    
        before_filter :set_guard_on