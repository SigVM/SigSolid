pragma solidity ^0.6.9;

// Test to see if a signal can broadcast to multiple slots.

// Emitter
contract Emitter {
    signal Alert(bytes32 value);

    function send_alert(bytes32 value) public {
        emitsig Alert(value).delay(0);
    }
}

// First listener
contract ReceiverA {
    bytes32 private data;

    slot HandleAlert(bytes32 value) {
        data = value;
    }

    function get_data() public view returns (bytes32 ret) {
        ret = data;
    }

    function bind_to_alert(Emitter addr) public view {
        HandleAlert.bind(addr.Alert);
    }
}

// Second listener
contract ReceiverB {
    bytes32 private data;

    slot HandleAlert(bytes32 value) {
        data = value;
    }

    function get_data() public view returns (bytes32 ret) {
        ret = data;
    }

    function bind_to_alert(Emitter addr) public view {
        HandleAlert.bind(addr.Alert);
    }
}