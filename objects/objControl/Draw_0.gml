c.builder.Draw()

struct_foreach(c, function(k, v) {
    if k == "builder" {
        return
    }
    v.Draw()
})


struct_foreach(help, function(_, v) {
    v.Draw()
})

