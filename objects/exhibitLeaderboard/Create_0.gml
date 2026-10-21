event_inherited();


SelectAdd = 0
SelectRemove = 1

name = "Scoreboat V" + SB_VERSION


step = 0;


sb_init("8xvgXd2", "uejwbGmvN2VX8IhG", "NKkGVKBpyc38c83HMhqxs_FaEZ5QwtVU8BdmhNb7rUI")
        .success(function(_info) {
            show_debug_message("Scoreboat is ready");
        })
        .fail(function(_error) {
            show_debug_message("Scoreboat failed: " + _error.message);
        });

LeaderBoardId = "K0qviVwQrr"