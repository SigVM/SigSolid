pragma solidity ^0.7.0;

// Multiple argument emits.
contract SelfAlerter {
    signal BigAlert(string, uint8[5], uint32);
    handler BigHandler(string, uint8[5], uint32);
    string fooo;
    uint8[] barr;
    uint32 bazz;
    function update(string calldata foo, uint8[5] calldata bar, uint32 baz) public {
        fooo = foo;
        barr = bar;
        bazz = baz;
        return;
    }
    function signal_emit() public view {
        string memory foo = "Hello World!";
        uint8[5] memory bar = ([1, 1, 2, 2, 4]);
        uint32 baz = 42;
        BigAlert.emit(foo, bar, baz).delay(1);
    }
    constructor() {
        BigAlert.create_signal();
        BigHandler.create_handler("update(string,uint8[5],uint32)", 1000000, 120);
        address this_address = address(this);
        BigHandler.bind(this_address, "BigAlert(string,uint8[5],uint32)");
    }
}