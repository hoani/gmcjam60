function RefreshSurface(surf, w, h) {
    if !surface_exists(surf) {
        surf = surface_create(w, h)
    }
    return surf
}