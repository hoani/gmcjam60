/// @description Global particle object

last_step = 0
global.p = self

// back particle system
ba = part_system_create()
part_system_automatic_update(ba, false)
part_system_depth( ba, ParticleDepthBehind());

// front particle system
fa = part_system_create()
part_system_automatic_update(fa, false)
part_system_depth( fa, ParticleDepthFront() );

registry = [];

register = function(input) {
    array_push(registry, input);
}

b_dust = new DustParticles(ba, 0.5, C_YELLOW);
f_dust = new DustParticles(fa, 0.5);
register(b_dust);
register(f_dust);

spark = new SparkParticles(fa);
register(spark);
