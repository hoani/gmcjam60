// Inherit the parent event
event_inherited();

// Note hp = 2 by default

notifier = new DummyBreakNotifier()

Register = function(n) {
    notifier = n
}

OnImpulse = function(impulse) {
    if impulse < 0.5 {
        return
    }
    DebugMessage($"Impule hit {impulse}")
    if impulse > 1 {
        hp -= impulse
    }
    
    if hp < 0 {
        notifier.OnBreak()
        instance_destroy()
    }
} 

OnOutOfBounds = function() {
    notifier.OnOutOfBounds()
    instance_destroy()
}