

magnitude = spd.Distance()
unit = spd.Unit().Rotate(180)
orth = unit.Copy().Rotate(90)
a = unit.Copy().Rotate(30)
b = unit.Copy().Rotate(-30)


main = new Cooldown(15 + magnitude)
flare = new Cooldown(magnitude/2)
main.Trigger()
flare.Trigger()
