
// The library's version. A released package has its own here, such as "1.2.0";
// a copy built from source says "dev".
#macro SB_VERSION "0.3.0"

// Where Scoreboat is. A released package points at the hosted service.
/// @ignore
#macro _sb_host "https://scoreboat.net/api/"

// Seconds before a token expires that it is refreshed, and the longest wait
// between attempts when refreshing keeps failing.
/// @ignore
#macro _sb_refresh_margin 300
/// @ignore
#macro _sb_refresh_max_backoff 300

// Where the library keeps what a player needs to be the same player next time
// the game runs: their guest secret, or the refresh token of their sign-in.
/// @ignore
#macro _sb_player_store "scoreboat_players.ini"