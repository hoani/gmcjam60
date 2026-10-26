// Inherit the parent event
event_inherited();

// Note hp = 2 by default
maxhp = hp
damageMultiplier = 1

notifier = new DummyBreakNotifier()

Register = function(n) {
    notifier = n
}

OnImpulse = function(impulse) {
    impulse = impulse.Multiply(damageMultiplier)
    if impulse.Distance() < 0.5 {
        return
    }
    DebugMessage($"Impule hit {impulse}")
    hp -= impulse.Distance()
    
    if hp < 0 {
        notifier.OnBreak()
        InstanceCreate(x, y, objEggSplat, {impulse: impulse})
        instance_destroy()
    }
} 

OnOutOfBounds = function() {
    notifier.OnOutOfBounds()
    CommonOutOfBounds()
}