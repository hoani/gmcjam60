
/// @ignore
function __sb_hex_to_buffer(_hex)
{
    var _size = string_length(_hex) div 2;
    var _buffer = buffer_create(max(_size, 1), buffer_fixed, 1);
    var _i = 0;
    repeat(_size)
    {
        var _hi = ord(string_char_at(_hex, 2*_i + 1));
        var _lo = ord(string_char_at(_hex, 2*_i + 2));
        _hi = (_hi <= 57)? (_hi - 48) : ((_hi | 32) - 87);
        _lo = (_lo <= 57)? (_lo - 48) : ((_lo | 32) - 87);
        buffer_write(_buffer, buffer_u8, (_hi << 4) | _lo);
        ++_i;
    }
    return _buffer;
}

/// Hex to url-safe base64 without padding, the encoding the server expects.
/// @ignore
function __sb_base64url_from_hex(_hex)
{
    var _buffer = __sb_hex_to_buffer(_hex);
    var _string = buffer_base64_encode(_buffer, 0, string_length(_hex) div 2);
    buffer_delete(_buffer);
    _string = string_replace_all(_string, "+", "-");
    _string = string_replace_all(_string, "/", "_");
    return string_replace_all(_string, "=", "");
}

/// The requested permissions sorted and joined with '|'. None requested (an
/// empty array, undefined or JSON null) is the empty string.
/// @ignore
function __sb_scope_digest(_permissions)
{
    if (!is_array(_permissions) || (array_length(_permissions) == 0)) return "";
    var _sorted = array_create(array_length(_permissions));
    array_copy(_sorted, 0, _permissions, 0, array_length(_permissions));
    array_sort(_sorted, true);
    return string_join_ext("|", _sorted);
}

/// The string the client signs: <request_id>.<nonce>.<unix_ts>.<permissions>
/// @ignore
function __sb_build_message(_request_id, _nonce, _unix_ts, _permissions)
{
    // int64 so a large timestamp never prints as a float.
    return _request_id + "." + _nonce + "." + string(int64(_unix_ts)) + "." + __sb_scope_digest(_permissions);
}

/// The proof for an hmac-sha256 key.
/// @ignore
function __sb_proof_hmac(_secret, _message)
{
    return __sb_base64url_from_hex(hmac_sha256(_secret, _message));
}