event_inherited()

name = "Text Experiments"

var _ipsum = "Bacon ipsum dolor amet filet mignon beef shank, turkey tail burgdoggen pork belly kevin shankle short loin sausage. Leberkas brisket short loin alcatra pancetta capicola kevin jerky pork belly chislic pastrami short ribs pork chop. Tenderloin short loin pastrami ball tip pork chuck prosciutto. Sausage boudin salami bresaola kielbasa corned beef turducken drumstick filet mignon porchetta pork chislic burgdoggen. Ground round cupim pork belly shankle turducken turkey sausage rump spare ribs brisket t-bone capicola."

var _scaling = $"{ChScale(0.5)}Bacon {CH_SYMBOL_HEART}{CH_SCALE_RESET}ipsum {ChScale(1.25)}Bacon{CH_SYMBOL_HEART}{CH_SCALE_RESET}"

var _mix = $"Bacon {CH_SYMBOL_HEART} capicola."

var _symbols = $"{CH_SYMBOL_HEART}{CH_SYMBOL_HEART}{CH_SYMBOL_HEART}{CH_SYMBOL_HEART}{CH_SYMBOL_HEART}{CH_SYMBOL_HEART}{CH_SYMBOL_HEART}{CH_SYMBOL_HEART}{CH_SYMBOL_HEART} {CH_SYMBOL_HEART}{CH_SYMBOL_HEART}{CH_SYMBOL_HEART}"

var _colored = $"{CH_COL_LTRED}Hello{CH_COL_RESET} World. {CH_COL_LTGREEN}{CH_SYMBOL_HEART}{CH_COL_RESET}"

var _alphaed = $"{ChAlpha(0.75)}H{ChAlpha(0.5)}e{ChAlpha(0.25)}l{ChAlpha(0.5)}l{ChAlpha(0.75)}o{CH_ALPHA_RESET} World. {ChAlpha(0.5)}{CH_SYMBOL_HEART}{CH_ALPHA_RESET}"

var _wavey = $"{ChWave(0.5, 1)}Hello {ChWave(1/16, 0.125)}{ChScale(1.5)}Everyone{CH_SCALE_RESET} In The {CH_FX_RESET} World. {ChWave(0.5, 1)}{string_repeat(CH_SYMBOL_HEART, 32)}{CH_FX_RESET}"

texts = [
    ZooTextBox("FadeAppear", _ipsum, f_test, 64, 64, 512, 9999, new FadeAppear(30, 1)),
    ZooTextBox("scaling", _scaling, f_test, 128 + 512, 64, 512, 9999),
    ZooTextBox("f_test(CH_SYMBOL_HEART)", _mix, f_test, 128 + 512, 290, 512, 9999),
    ZooTextBox("f_mono(CH_SYMBOL_HEART)", _mix, f_mono, 128 + 512, 350, 512, 9999),
    ZooTextBox("symbol linebreak", _symbols, f_mono, 128 + 512, 390, 9*16, 9999),
    ZooTextBox("colors f_mono", _colored, f_mono, 128 + 512, 450, 512, 9999),
    ZooTextBox("colors f_test", _colored, f_test, 128 + 512, 490, 512, 9999),
    ZooTextBox("alpha", _alphaed, f_test, 128 + 512, 550, 512, 9999),
    ZooTextBox("ChWave", _wavey, f_test, 128 + 512, 620, 512, 9999),
]
