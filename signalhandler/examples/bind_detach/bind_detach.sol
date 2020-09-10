pragma solidity ^0.7.0;

// This contract is used to test basic functionality of binding and detaching to signals.
contract Emitter {
    signal Alert();
    function emit_alert() public view {
        Alert.emit().delay(0);
    }
    constructor() {
        Alert.create_signal();
    }
}
contract Receiver {
    uint updated;
    handler Receive();
    function update_data() public {
        updated = 1;
        return;
    }
    function bind_to_alert(address source) public view {
        Receive.bind(source, "Alert()");
    }
    function detach_from_alert(address source) public view {
        Receive.detach(source, "Alert()");
    }
    constructor() {
        Receive.create_handler("update_data()", 100000, 120);
        updated = 0;
    }
}