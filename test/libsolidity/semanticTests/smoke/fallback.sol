contract A {
    uint public data;
    uint public balance;
    function() external payable {
        data = 1;
        balance = msg.value;
    }
}
// ----
// data() -> 0
// ()
// data() -> 1
// (), 1 ether
// balance() -> 1