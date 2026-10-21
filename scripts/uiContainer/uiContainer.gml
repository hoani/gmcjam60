// Defines a container with outer and inner boxes.
// xpad, ypad define the padding between inner and outer elements
// xmargin and ymargin define a margin between the outer and the overall dimensions.
// xoffset and yoffset shift the position of the outerbox, which also shrinks the overall container.
function UiContainer(w, h, xpad=8, ypad=8, xmargin=0, ymargin=0, xoff = 0, yoff = 0) constructor {
    var xpos = w/2 + xoff/2;
    var ypos = h/2 + yoff/2;
    w = w - abs(xoff);
    h = h - abs(yoff);
    outer = new PositionedBox(xpos, ypos, w - 2*xmargin, h - 2*ymargin);
    inner = new PositionedBox(xpos, ypos, outer.w - 2*xpad, outer.h - 2*ypad);
}
