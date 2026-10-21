/// Percent-encodes a string for use in a URL.
/// @ignore
function __sb_url_encode(_string){
	static _hex = "0123456789ABCDEF";
	var _out = "";
	var _length = string_byte_length(_string);
	for(var _i = 1; _i <= _length; _i++){
		var _byte = string_byte_at(_string, _i);
		var _unreserved = (_byte >= 48 && _byte <= 57) || (_byte >= 65 && _byte <= 90) || (_byte >= 97 && _byte <= 122)
			|| _byte == 45 || _byte == 46 || _byte == 95 || _byte == 126;
		if(_unreserved) _out += chr(_byte);
		else _out += "%" + string_char_at(_hex, (_byte >> 4) + 1) + string_char_at(_hex, (_byte & 15) + 1);
	}
	return _out;
}