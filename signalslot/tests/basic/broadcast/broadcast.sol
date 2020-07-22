pragma solidity ^0.6.9;

// Test to see if a 'signal' can bind to multiple

// Emitter
contract Emitter {
    signal Alert(bytes32 value);

    function send_alert(bytes32 value) public {
        emitsig Alert(value).delay(0);
    }
}

// First listener
contract ReceiverA {
    Emitter source;
    bytes32 private data;

    slot HandleAlert(bytes32 value) {
        data = value;
    }

    function get_data() public view returns (bytes32 ret) {
        ret = data;
    }

    constructor(Emitter addr) public {
        source = addr;
        HandleAlert.bind(source.Alert);
    }
}

// Second listener
contract ReceiverB {
    Emitter source;
    bytes32 private data;

    slot HandleAlert(bytes32 value) {
        data = value;
    }

    function get_data() public view returns (bytes32 ret) {
        ret = data;
    }

    constructor(Emitter addr) public {
        source = addr;
        HandleAlert.bind(source.Alert);
    }
}