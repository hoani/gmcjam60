event_inherited()

name = "Appear/Disappear"


var _base = "Drumstick boudin turkey, eu ex ullamco chuck frankfurter sunt."

var _items = [
    {name: "FadeAppear(8, 1)", appear: new FadeAppear(8, 1), disappear: new TextAppear()},
    {name: "FadeAppear(4, 1)", appear: new FadeAppear(4, 1), disappear: new TextAppear()},
    {name: "FadeAppear(4, 4), FadeOut(30)", appear: new FadeAppear(4, 4), disappear: new FadeOut(30)},
];

texts = []

var xpos = 64;
var ypos = 64;

for (var i = 0; i < array_length(_items); i++) {
    var item = _items[i]
    var textbox = ZooTextBox(item.name, _base, f_test, xpos, ypos, 512, 9999, item.appear, item.disappear)
    array_push(texts, textbox)
    
    ypos += textbox.text.Dimensions().h + 24
    
    if ypos > room_height - (textbox.text.Dimensions().h + 32) {
        ypos = 64;
        xpos += 512 + 32;
    }
}
