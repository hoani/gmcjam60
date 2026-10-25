c.builder.Draw()

struct_foreach(c, function(k, v) {
    if k == "builder" {
        return
    }
    v.Draw()
})

