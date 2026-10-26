function BumperSfx() {
    if !variable_global_exists("bumperSfx") {
        global.bumperSfx = new SfxSequence([sndBumper0, sndBumper1, sndBumper2, sndBumper3, sndBumper4])
    }
    return global.bumperSfx.Get()
}