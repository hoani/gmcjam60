
/// Common HP tracking class.
/// @arg _max - maximum health.
/// @arg _invulnerable_steps - how many frames to be invulnerable after taking damage
/// @arg _on_damage - callback to trigger after taking damage
function Hp(_max, _invulnerable_steps, _on_damage) constructor {
    current = _max;
    maximum = _max;
    invulnerable_count = 0;
    invulnerable_steps = _invulnerable_steps;
    on_damage = _on_damage;
    
    static Update = function() {
    	if invulnerable_count > 0 {
    		invulnerable_count -= GameSpeed().Get(1);
    		if invulnerable_count < 0 {
    			invulnerable_count = 0;
    		}
    	}
    }
    
    static Invulnerable = function() {
        return invulnerable_count > 0;
    }
    
    static Damage = function(_amount=1) {
        if current <= 0 || invulnerable() {
    		return
    	}
    		
    	current -= _amount;
    	invulnerable_count = invulnerable_steps;
    	
    	on_damage();
    }
    
    static Blink = function(_period=2) {
        if current <= 0 || invulnerable() {
    		return false;
    	}
        
        return invulnerable_count % _period >= _period/2;
    }
    
    static Draw = function(_x, _y, _spr, _dx=0, _dy=8) {
    	for (var _i=0; _i <maximum; _i++) {
    		var _img = _i < current ? 0 : 1;
    		draw_sprite(_spr, _img, _x+_i*_dx, _y+_i*_dy)	
    	}
    }
}

