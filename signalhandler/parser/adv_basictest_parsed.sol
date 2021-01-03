pragma solidity ^0.7.0;

contract A {
// Original code: signal Alert1(bool,bytes32,address);
bytes32 private Alert1_key;
function set_Alert1_key() private {
    Alert1_key = keccak256("Alert1(bool,bytes32,address)");
}
////////////////////
// Original code: signal Alert2(bool,bytes32,address);
bytes32 private Alert2_key;
function set_Alert2_key() private {
    Alert2_key = keccak256("Alert2(bool,bytes32,address)");
}
////////////////////
    bool fooo;
    bytes32 barr;
    address bazz;

// Original code: function AlertUpdate(bool foo, bytes32 bar, address baz) handler {
bytes32 private AlertUpdate_key;
function set_AlertUpdate_key() private {
    AlertUpdate_key = keccak256("AlertUpdate(bool,bytes32,address)");
}
function AlertUpdate(bool foo, bytes32 bar, address baz) public {
////////////////////
        fooo = foo;
        barr = bar;
        bazz = baz;
        return;
    }
// Original code: function AdvAlertUpdate(bool foo, bytes32 bar, address baz) handler {
bytes32 private AdvAlertUpdate_key;
function set_AdvAlertUpdate_key() private {
    AdvAlertUpdate_key = keccak256("AdvAlertUpdate(bool,bytes32,address)");
}
function AdvAlertUpdate(bool foo, bytes32 bar, address baz) public {
////////////////////
        fooo = !foo;
        barr = ~bar;
        bazz = address(this);
        return;
    }

    function cleanup() public {
// Original code: Alert1.delete_signal();
Alert1_key = 0;
assembly {
    mstore(0x00, deletesignal(sload(Alert1_key.slot)))
}
////////////////////
// Original code: Alert2.delete_signal();
Alert2_key = 0;
assembly {
    mstore(0x00, deletesignal(sload(Alert2_key.slot)))
}
////////////////////
// Original code: AlertUpdate.delete_handler();
AlertUpdate_key = 0;
assembly {
    mstore(0x00, deletehandler(sload(AlertUpdate_key.slot)))
}
////////////////////
    }

    function binding() public {
        address this_address = address(this);
// Original code: AlertUpdate.bind(this_address,"Alert1(bool,bytes32,address)",0.46);
set_AlertUpdate_key();
bytes32 AlertUpdate_method_hash = keccak256("AlertUpdate(bool,bytes32,address)");
uint AlertUpdate_gas_limit = 100000000;
uint AlertUpdate_gas_ratio = 146;
assembly {
    mstore(
        0x00, 
        createhandler(
            sload(AlertUpdate_key.slot), 
            AlertUpdate_method_hash, 
            AlertUpdate_gas_limit, 
            AlertUpdate_gas_ratio
        )
    )
}
bytes32 AlertUpdate_signal_prototype_hash = keccak256("Alert1(bool,bytes32,address)");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(AlertUpdate_key.slot),
            this_address,
            AlertUpdate_signal_prototype_hash
        )
    )
}
////////////////////
    }
    
    function emitting(address data3) public view {
        bool xfoo = true;
        bytes32 xbar = 0;
        address xbaz = data3;
// Original code: Alert1.emit(xfoo,xbar,xbaz).delay(5);
bytes memory abi_encoded_Alert1_data = abi.encode(xfoo,xbar,xbaz);
// This length is measured in bytes and is always a multiple of 32.
uint abi_encoded_Alert1_length = abi_encoded_Alert1_data.length;
assembly {
    mstore(
        0x00,
        sigemit(
            sload(Alert1_key.slot), 
            abi_encoded_Alert1_data,
            abi_encoded_Alert1_length,
            5
        )
    )
}
////////////////////
// Original code: Alert2.emit(xfoo,xbar,xbaz).delay(15);
bytes memory abi_encoded_Alert2_data = abi.encode(xfoo,xbar,xbaz);
// This length is measured in bytes and is always a multiple of 32.
uint abi_encoded_Alert2_length = abi_encoded_Alert2_data.length;
assembly {
    mstore(
        0x00,
        sigemit(
            sload(Alert2_key.slot), 
            abi_encoded_Alert2_data,
            abi_encoded_Alert2_length,
            15
        )
    )
}
////////////////////
    }

    function detaching() public view {
        address this_address = address(this);
// Original code: AlertUpdate.detach(this_address,"Alert1(bool,bytes32,address)");
bytes32 AlertUpdate_signal_prototype_hash = keccak256("Alert1(bool,bytes32,address)");
assembly {
    mstore(
        0x00,
        sigdetach(
            sload(AlertUpdate_key.slot),
            this_address,
            AlertUpdate_signal_prototype_hash
        )
    )
}
////////////////////
    }

    constructor () {
// Auto create signal
set_Alert1_key();
assembly {
    mstore(0x00, createsignal(sload(Alert1_key.slot)))
}
////////////////////
// Auto create signal
set_Alert2_key();
assembly {
    mstore(0x00, createsignal(sload(Alert2_key.slot)))
}
////////////////////
        address this_address = address(this);
// Original code: AlertUpdate.bind(this_address,"Alert1(bool,bytes32,address)",0.3);
set_AlertUpdate_key();
bytes32 AlertUpdate_method_hash = keccak256("AlertUpdate(bool,bytes32,address)");
uint AlertUpdate_gas_limit = 100000000;
uint AlertUpdate_gas_ratio = 130;
assembly {
    mstore(
        0x00, 
        createhandler(
            sload(AlertUpdate_key.slot), 
            AlertUpdate_method_hash, 
            AlertUpdate_gas_limit, 
            AlertUpdate_gas_ratio
        )
    )
}
bytes32 AlertUpdate_signal_prototype_hash = keccak256("Alert1(bool,bytes32,address)");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(AlertUpdate_key.slot),
            this_address,
            AlertUpdate_signal_prototype_hash
        )
    )
}
////////////////////
// Original code: AdvAlertUpdate.bind(this_address,"Alert2(bool,bytes32,address)",0.78);
set_AdvAlertUpdate_key();
bytes32 AdvAlertUpdate_method_hash = keccak256("AdvAlertUpdate(bool,bytes32,address)");
uint AdvAlertUpdate_gas_limit = 100000000;
uint AdvAlertUpdate_gas_ratio = 178;
assembly {
    mstore(
        0x00, 
        createhandler(
            sload(AdvAlertUpdate_key.slot), 
            AdvAlertUpdate_method_hash, 
            AdvAlertUpdate_gas_limit, 
            AdvAlertUpdate_gas_ratio
        )
    )
}
bytes32 AdvAlertUpdate_signal_prototype_hash = keccak256("Alert2(bool,bytes32,address)");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(AdvAlertUpdate_key.slot),
            this_address,
            AdvAlertUpdate_signal_prototype_hash
        )
    )
}
////////////////////
    }
}
