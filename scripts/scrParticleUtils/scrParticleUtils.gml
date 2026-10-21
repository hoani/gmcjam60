
// This is just a number to try and keep particles on a different layer to other things.
#macro PARTICLE_DEPTH 10


/// calculates the particles to emit based on a count_per_frame input and normalizes it against the global game speed.
/// Useful for still emitting a consistent particle effect when making the game "speed" move in slow motion.
/// @arg count_per_frame - how many particles to emit per frame at 1x speed.
function CalculateParticleCount(count_per_frame) {
	var count = GameSpeed().Get(count_per_frame)
	if count%1 != 0 {
		if random(1) < count%1 {
			count = floor(count) + 1
		} else {
			count = floor(count)
		}
	}
	return count
}


function ParticleDepthBehind() {
    return layer_get_depth(LAYER_WORLD) + PARTICLE_DEPTH;
}


function ParticleDepthFront() {
    return layer_get_depth(LAYER_WORLD) - PARTICLE_DEPTH;
}