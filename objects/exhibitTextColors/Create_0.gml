event_inherited()

name = "Colors"


var _base = "Hello World"

var _items = [
    {name: "CH_COL_BLACK", input: CH_COL_BLACK},
    {name: "CH_COL_DKGRAY", input: CH_COL_DKGRAY},
    {name: "CH_COL_GRAY", input: CH_COL_GRAY},
    {name: "CH_COL_LTGRAY", input: CH_COL_LTGRAY},
    {name: "CH_COL_WHITE", input: CH_COL_WHITE},
    {name: "CH_COL_DKRED", input: CH_COL_DKRED},
    {name: "CH_COL_RED", input: CH_COL_RED},
    {name: "CH_COL_LTRED", input: CH_COL_LTRED},
    {name: "CH_COL_DKGREEN", input: CH_COL_DKGREEN},
    {name: "CH_COL_GREEN", input: CH_COL_GREEN},
    {name: "CH_COL_LTGREEN", input: CH_COL_LTGREEN},
    //{name: "CH_COL_", input: CH_COL_},
];

texts = []

var xpos = 64;
var ypos = 64;

for (var i = 0; i < array_length(_items); i++) {
    var item = _items[i]
    var textbox = ZooTextBox(item.name, $"{item.input}{_base}{CH_COL_RESET}", f_test, xpos, ypos, 196, 9999)
    array_push(texts, textbox)
    
    ypos += textbox.text.Dimensions().h + 24
    
    if ypos > room_height - (textbox.text.Dimensions().h + 32) {
        ypos = 64;
        xpos += 224;
    }
}