

if (!loader.is_finished) {
    event_user(0); // process the loader phase
} else if (!runner.is_finished) {
    event_user(1); // process the runner phase
} else if (root.status_counter.passed == root.status_counter.total) {
    // All tests passed, show this in the console pane and move on.
    show_debug_message($"{root.status_counter.passed} of {root.status_counter.passed} Tests passed.");
    instance_destroy();
}