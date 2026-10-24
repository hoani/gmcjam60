
function Navigator(width=512, _ypos=room_height/2, _xpos = room_width/2) {
    return new UiNavigator(width, _ypos, _xpos)
}


function UiNavigator(width=512, _ypos=room_height/2, _xpos = room_width/2) constructor {
    selector = new Selector(width, _ypos, _xpos)
    options = []
    active = []
    uid = GetUniqueId()
    onSelected = undefined;
    
    pos = new Vec2(_xpos, _ypos)
    font = fScrawlingPad
    
    page = 0
    optionsPerPage = 8
    
    var pPos = pos.Add(new Vec2(-(width/2 + 16),0))
    var nPos = pos.Add(new Vec2((width/2 + 16), 0))
    
    
    PrevPage = function() {
        var numPages = ceil(array_length(options)/optionsPerPage);
        page = (page + numPages - 1) % numPages
        Refresh(options, onSelected)
    }
    
     NextPage = function() {
        var numPages = ceil(array_length(options)/optionsPerPage);
        page = (page + 1) % numPages
        Refresh(options, onSelected)
    }
    
    buttons = [
        Button(pPos, sprPrev, PrevPage).HRight().VCenter(),
        Button(nPos, sprNext, NextPage).HLeft().VCenter()
    ]
    
    static OptionsPerPage = function(val) {
        optionsPerPage = val
    }
    
    static Cleanup = function() {
        selector.Cleanup()
    }
    
    static _Offset = function() {
        return page*optionsPerPage
    }
    
    static Refresh = function(_options, _onSelected) {
        options = _options
        onSelected = _onSelected
        active = []
        
        array_copy(active, 0, options, _Offset(), optionsPerPage)
        
        selector.Refresh(active, function(i){
            onSelected(i + _Offset())
        })
    }
    
    static Activate = function(_options, _onSelected) {
        Refresh(_options, _onSelected)
    }
    
    
    static Update = function() {
        if !InControlStack(uid) {
            return
        }
        var numPages = ceil(array_length(options)/optionsPerPage);
        if numPages > 1 {
            array_foreach(buttons, function(b){
                b._Update()
            })
        }
        
        if !IsActiveControl(uid) {
            selector.Unhover()
            return
        }
        selector.Update()
    }
    
    static Draw = function() {
        selector.Draw()
        
        var numPages = ceil(array_length(options)/optionsPerPage);
        if numPages > 1 {
            array_foreach(buttons, function(b){
                b._Draw()
            })
        }
    }
}

