function phyBodyJoinable(){
    joins = []
    
    static Cleanup = function() {
        for (var _i = 0; _i < array_length(joins); _i++) {
        	if instance_exists(joins[_i]) {
        		instance_destroy(joins[_i])
        	}
        }
    }
}