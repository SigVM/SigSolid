pragma solidity ^0.7.0;

contract Emitter {
// Original code: signal Alert();
bytes32 private Alert_key;
function set_Alert_key() private {
    Alert_key = keccak256("Alert()");
}
////////////////////
    function emit_alert() public view {
// Original code: Alert.emit().delay(0);
assembly {
    mstore(
        0x00,
        sigemit(
            sload(Alert_key.slot), 
            0,
            0,
            0
        )
    )
}
////////////////////
    }
    constructor() {
// Original code: Alert.create_signal();
set_Alert_key();
assembly {
    mstore(0x00, createsignal(sload(Alert_key.slot)))
}
////////////////////
    }
}
contract Receiver {
    uint updated;
// Original code: handler Receive;
bytes32 private Receive_key;
function set_Receive_key() private {
    Receive_key = keccak256("Receive()");
}
////////////////////
    function update_data() public {
        updated = 1;
        return;
    }
    function bind_to_alert(address source) public view {
// Original code: Receive.bind(source,"Alert()");
bytes32 Receive_signal_prototype_hash = keccak256("Alert()");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(Receive_key.slot),
            source,
            Receive_signal_prototype_hash
        )
    )
}
////////////////////
    }
    function detach_from_alert(address source) public view {
// Original code: Receive.detach(source,"Alert()");
bytes32 Receive_signal_prototype_hash = keccak256("Alert()");
assembly {
    mstore(
        0x00,
        sigdetach(
            sload(Receive_key.slot),
            source,
            Receive_signal_prototype_hash
        )
    )
}
////////////////////
    }
    constructor() {
// Original code: Receive.create_handler("update_data()",100000,120);
set_Receive_key();
bytes32 Receive_method_hash = keccak256("update_data()");
uint Receive_gas_limit = 100000;
uint Receive_gas_ratio = 120;
assembly {
    mstore(
        0x00, 
        createhandler(
            sload(Receive_key.slot), 
            Receive_method_hash, 
            Receive_gas_limit, 
            Receive_gas_ratio
        )
    )
}
////////////////////
        updated = 0;
    }
}