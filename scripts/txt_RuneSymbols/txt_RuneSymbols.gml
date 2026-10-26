#macro CH_SYMBOL (0x80)
#macro CH_SYMBOL_HEART ("\u8000")
#macro CH_SYMBOL_BOLT ("\u8001")
#macro CH_SYMBOL_PLAY ("\u8002")

function ChRepeats(symbol, repeats=1) {
    if repeats > 3 {
        return $"{symbol}x{repeats}"
    }
    return string_repeat(symbol, repeats)
}

function ChEnergy(repeats=1) {
    return ChRepeats(CH_SYMBOL_ENERGY, repeats)
}

function ChSouls(repeats=1) {
    return ChRepeats(CH_SYMBOL_SOULS, repeats)
}

