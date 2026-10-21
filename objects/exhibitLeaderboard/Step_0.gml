event_inherited()



if sb_ready() {
    if step == 0 {
        name = "Scoreboat V" + SB_VERSION + " READY"
    }
    step++
    
    
    if step % 300 == 60 {
        scores = sb_leaderboard_scores(LeaderBoardId, {}, function(board){
            show_debug_message(board)
            
            labels = []
            for (var i = 0; i < array_length(board.scores); i++) {
                entry = board.scores[i]
                NewLabel($"Rank {entry.rank} {entry.player_name}({entry.player})  -  {entry.score}", room_width/2, 64 + i*32)
            }
        })
    }
    
    if step == 120 {
        sb_leaderboard_submit(LeaderBoardId, "Bilbo Baggins", 69, {}, function() {
            show_debug_message("submitted score")
        },
        function() {
            show_debug_message("score not submitted")
        })
    }
}
