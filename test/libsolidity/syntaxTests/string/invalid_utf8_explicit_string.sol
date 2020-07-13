contract C {
    string s = string(unicode"\xa0\x00");
}
// ----
// SyntaxError 8452: (35-52): Non-Unicode characters found
// TypeError 9640: (28-53): Explicit type conversion not allowed from "literal_string (contains invalid UTF-8 sequence at position 0)" to "string memory".
