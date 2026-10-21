/// @description Clean up particle systems.

while (array_length(registry)>0) {
    var item = array_pop(registry);
    item.Cleanup();
}

part_system_destroy(ba)
part_system_destroy(fa)
