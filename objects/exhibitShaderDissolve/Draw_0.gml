event_inherited()

var _amount = (count % 256) / 256

shader_set(shd_dissolve);
var _uniform_amount = shader_get_uniform(shd_dissolve, "amount");
shader_set_uniform_f(_uniform_amount, _amount);

text.Draw(100, 100)

shader_reset();


shader_set(shd_dissolve_horizontal);
_uniform_amount = shader_get_uniform(shd_dissolve_horizontal, "amount");
shader_set_uniform_f(_uniform_amount, _amount);

text.Draw(room_width/2, 100)

shader_reset();



