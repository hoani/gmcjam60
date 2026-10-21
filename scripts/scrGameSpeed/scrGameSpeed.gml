
function GameSpeedClass() constructor {
	m = 1.0
    
    static Get = function(_base) {
        return m*_base
    } 
    
    static Accelerate = function(_base, _accel) {
        return _base + m * _accel
    }
}




