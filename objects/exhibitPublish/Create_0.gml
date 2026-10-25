event_inherited();



name = "Publish"


publish = new Publish(function() {
    DebugMessage("Publishing...")
    publish.Done("Publish Succeeded")
}, function() {
    DebugMessage("Publish Form Done")
})

PushControlStack(publish.uid)