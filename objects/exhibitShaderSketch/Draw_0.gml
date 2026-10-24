event_inherited()

shader_set(shSketch);

shader_set_uniform_f(shader_get_uniform(shSketch, "u_frame"), count);

text.Draw(100, 100)
//draw_sprite_ext(sprScreenCharacter, 0, 200, 300, 3, 3, 0, c_white, 1)

shader_reset();


shader_set(shWobble);

shader_set_uniform_f(shader_get_uniform(shWobble, "u_frame"), count);

text.Draw(100, 200)
//draw_sprite_ext(sprScreenCharacter, 0, 200, 300, 3, 3, 0, c_white, 1)

shader_reset();
