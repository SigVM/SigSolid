pragma solidity ^0.6.9;

// Test to see if a signal can broadcast to multiple slots.
// Check that slot transactions are created for both receivers
// when the signal is emitted.

contract Emitter {
    signal Alert();
    function send_alert() public view {
        emitsig Alert().delay(0);
    }
}

contract ReceiverA {
    bytes32 private data;
    slot HandleAlert() {
        data = 0;
    }
    function bind_to_alert(Emitter addr) public view {
        HandleAlert.bind(addr.Alert);
    }
}

contract ReceiverB {
    bytes32 private data;
    slot HandleAlert() {
        data = 0;
    }
    function bind_to_alert(Emitter addr) public view {
        HandleAlert.bind(addr.Alert);
    }
}