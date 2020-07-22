pragma solidity ^0.6.9;

// Test to see if one slot can successfully bind to multiple signals.
// One signal is emitted immediately while the other one is delayed.

// TODO: Including the full word 'signal' messes up the parser...
// Functionality test to see if a signall can be created.
contract EmitOnTime {
    bytes32 private data;
    signal Alert(bytes32 value);

    function send_alert(bytes32 value) public {
        data = data | value;
        emitsig Alert(data).delay(0);
    }

    function clear_data() public {
        data = 0;
    }

    constructor() public {
        data = 0;
    }
}

contract EmitLate {
    bytes32 private data;
    signal Alert(bytes32 value);

    function send_alert(bytes32 value) public {
        data = data | value;
        emitsig Alert(data).delay(10);
    }

    function clear_data() public {
        data = 0;
    }

    constructor() public {
        data = 0;
    }
}

// Multiple binds! Hopefully it works.
contract Receiver {
    EmitOnTime public on_time;
    EmitLate public late;

    // Count the number of 1's in the alert data. For what purpose? None...
    uint32 private alert_count;

    slot Receive(bytes32 data) {
        alert_count = 0;
        for(uint i = 0; i < 32; i++) {
            if(!(data[0] == 0x00)) {
                alert_count = alert_count + 1;
            }
            data = data >> 1;
        }
    }

    function get_alert_count() public view returns (uint32 ret) {
        ret = alert_count;
    }

    constructor(EmitOnTime first, EmitLate second) public {
        on_time = first;
        late = second;
        Receive.bind(on_time.Alert);
        Receive.bind(late.Alert);
    }
}