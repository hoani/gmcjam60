
if last_step != floor(Game().step) {
	part_system_update(ba)
	part_system_update(fa)
	last_step = floor(Game().step)
}