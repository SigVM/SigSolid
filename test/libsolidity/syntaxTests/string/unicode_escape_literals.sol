contract test {
    function oneByteUTF8() public pure returns (bytes32) {
        bytes32 usdollar = "aaa\u0024aaa";
        return usdollar;
    }

    function twoBytesUTF8() public pure returns (bytes32) {
        bytes32 cent = "aaa\u00A2aaa";
        return cent;
    }

    function threeBytesUTF8() public pure returns (bytes32) {
        bytes32 eur = "aaa\u20ACaaa";
        return  eur;
    }

    function combined() public pure returns (bytes32) {
        bytes32 res = "\u0024\u00A2\u20AC";
        return res;
    }
}
// ----
// SyntaxError 5811: (233-247): Non-ASCII characters found
// SyntaxError 5811: (361-375): Non-ASCII characters found
// SyntaxError 5811: (483-503): Non-ASCII characters found
