contract C {
    bytes b1 = "\xa0\x00";
    bytes32 b2 = "\xa0\x00";
    bytes b3 = hex"a000";
}
// ----
// SyntaxError 5811: (28-38): Non-ASCII characters found
// SyntaxError 5811: (57-67): Non-ASCII characters found
