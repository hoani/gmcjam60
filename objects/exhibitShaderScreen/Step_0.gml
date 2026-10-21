event_inherited()

pos = pos.Add(spd)

if pos.x != clamp(pos.x, 0, room_width) {
    spd.x = -spd.x
}
if pos.y != clamp(pos.y, 0, room_height) {
    spd.y = -spd.y
}
