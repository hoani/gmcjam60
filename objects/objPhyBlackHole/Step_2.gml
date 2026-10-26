var others = impulseDetect.GetOthers()

array_foreach(others, function(o) {
    with (o) {
        OnOutOfBounds()
    }
})