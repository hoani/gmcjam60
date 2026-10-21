event_inherited()

name = "Alignment"


var _short = "Hello World"
var _long = "Bacon ipsum dolor amet filet mignon beef shank, turkey tail burgdoggen pork belly kevin shankle short loin sausage."

var _items = [
    {name: "short_left", input: {t: _short, a: fa_left}},
    {name: "short_middle", input: {t: _short, a: fa_center}},
    {name: "short_right", input: {t: _short, a: fa_right}},
    {name: "long_left", input: {t: _long, a: fa_left}},
    {name: "long_middle", input: {t: _long, a: fa_center}},
    {name: "long_right", input: {t: _long, a: fa_right}},
];

texts = []

var xpos = 64;
var ypos = 64;

for (var i = 0; i < array_length(_items); i++) {
    var item = _items[i]
    var textbox = ZooTextBox(item.name, item.input.t, f_test, xpos, ypos, 512, 9999)
    textbox.align = item.input.a
    textbox.text.WithAlign(item.input.a)
    array_push(texts, textbox)
    
    ypos += textbox.text.Dimensions().h + 24
    
    if ypos > room_height - (textbox.text.Dimensions().h + 32) {
        ypos = 64;
        xpos += 620;
    }
}
