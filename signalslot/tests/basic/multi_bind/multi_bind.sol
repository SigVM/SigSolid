pragma solidity ^0.6.9;
// Test to see if one slot can successfully bind to multiple signals.
// One signal is emitted immediately while the other one is delayed.
contract EmitOnTime {
    signal Alert(bytes32 data);

    function send_alert(bytes32 data) public {
        emitsig Alert(data).delay(0);
    }
}
contract EmitLate {
    signal Alert(bytes32 data);

    function send_alert(bytes32 data) public {
        emitsig Alert(data).delay(10);
    }
}
// Multiple binds! Hopefully it works.
contract Receiver {
    bytes32 data;
    uint32 alert_count;

    slot Receive(bytes32 incoming_data) {
        data = incoming_data;
        alert_count = alert_count + 1;
    }
    function get_data() public view returns (bytes32 ret) {
        ret = data;
    }
    function get_alert_count() public view returns (uint32 ret) {
        ret = alert_count;
    }
    function bind_to_signal(address emitter) public view {
        Receive.bind(emitter.Alert);
    }
    constructor() public {
        data = 0;
        alert_count = 0;
    }
}