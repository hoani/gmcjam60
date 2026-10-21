/// @desc Explore suites

loader.visit_batch(1, 10.00);

if (loader.is_finished) {
    ui = instance_create_layer(0, 0, layer, ui_VerrificLogView, {
        "lines": lines});
    runner = new VerrificLogRunner(root);
}
