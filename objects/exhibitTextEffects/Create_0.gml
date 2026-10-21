event_inherited()

name = "Text Effects"


var _base = "Hello Everyone In The World"

var _waves = [
    {name: "0.5, 2", wave: $"{ChWave(0.5, 2)}"},
    {name: "0.5, 1", wave: $"{ChWave(0.5, 1)}"},
    {name: "0.5, 0.5", wave: $"{ChWave(0.5, 0.5)}"},
    {name: "0.5, 1/8", wave: $"{ChWave(0.5, 0.125)}"},
    {name: "1/8, 1", wave: $"{ChWave(1/8, 1)}"},
    {name: "1/32, 1", wave: $"{ChWave(1/32, 1)}"},
];

texts = []

var xpos = 64;
var ypos = 64;

for (var i = 0; i < array_length(_waves); i++) {
    var wave = _waves[i]
    array_push(
        texts,
        ZooTextBox($"ChWave({wave.name})", $"{wave.wave}Hello Everyone In The World{CH_FX_RESET}", f_test, xpos, ypos, 512, 9999)
    )
    ypos += 64
}
