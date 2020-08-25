pragma solidity ^0.6.9;

// TODO: Including the full word 'signal' messes up the parser...
// Functionality test to see if a signall can be created.
contract Emitter {
    signal Alert(bytes32 value);

    function send_alert(bytes32 value) public {
        emitsig Alert(value).delay(0);
    }
}

// Functionality test for listening to slots!
contract Receiver {
    Emitter source;
    bytes32 private data;

    slot HandleAlert(bytes32 value) {
        data = value;
    }

    function get_data() public view returns (bytes32 ret) {
        ret = data;
    }

    function bind_to_alert() public view {
        HandleAlert.bind(source.Alert);
    }

    function detach_from_alert() public view {
        HandleAlert.detach(source.Alert);
    }

    constructor(Emitter addr) public {
        source = addr;
        HandleAlert.bind(source.Alert);
    }
}