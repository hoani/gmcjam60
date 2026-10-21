event_inherited()

name = "Fonts"


var _base = "Drumstick boudin turkey. ?><!@#$%^&*()_+-="

var _fonts = [
    f_test, f_mono,
];

texts = []

var xpos = 48;
var ypos = 64;

for (var i = 0; i < array_length(_fonts); i++) {
    var f = _fonts[i]
    var textbox = ZooTextBox(font_get_name(f), _base, f, xpos, ypos, 512, 9999)
    array_push(texts, textbox)
    
    ypos += textbox.text.Dimensions().h + 32
    
    if ypos > room_height - 32 {
        ypos = 64;
        xpos += room_width/2
    }
}
