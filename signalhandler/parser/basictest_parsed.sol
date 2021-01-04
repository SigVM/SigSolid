pragma solidity ^0.7.0;

contract A {
// Original code: signal Alert(bool,bytes32,address);
bytes32 private Alert_key;
function set_Alert_key() private {
    Alert_key = keccak256("Alert(bool,bytes32,address)");
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

    function cleanup() public {
// Original code: Alert.delete_signal();
Alert_key = 0;
assembly {
    mstore(0x00, deletesignal(sload(Alert_key.slot)))
}
////////////////////
    }

    function binding() public {
        address this_address = address(this);
// Original code: AlertUpdate.bind(this_address,this.Alert(bool,bytes32,address),0.46);
set_AlertUpdate_key();
bytes32 AlertUpdate_method_hash = keccak256("AlertUpdate(bool,bytes32,address)");
uint AlertUpdate_gas_limit = 100000000;
uint AlertUpdate_gas_ratio = 146;
bytes32 AlertUpdate_signal_prototype_hash = keccak256("Alert(bool,bytes32,address)");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(AlertUpdate_key.slot),
            AlertUpdate_method_hash, 
            AlertUpdate_gas_limit, 
            AlertUpdate_gas_ratio,
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
// Original code: Alert.emit(xfoo,xbar,xbaz).delay(5);
bytes memory abi_encoded_Alert_data = abi.encode(xfoo,xbar,xbaz);
// This length is measured in bytes and is always a multiple of 32.
uint abi_encoded_Alert_length = abi_encoded_Alert_data.length;
assembly {
    mstore(
        0x00,
        sigemit(
            sload(Alert_key.slot), 
            abi_encoded_Alert_data,
            abi_encoded_Alert_length,
            5
        )
    )
}
////////////////////
    }

    function detaching() public view {
        address this_address = address(this);
// Original code: AlertUpdate.detach(this_address,this.Alert(bool,bytes32,address));
bytes32 AlertUpdate.detach(this_address, this_signal_prototype_hash = keccak256("Alert(bool,bytes32,address)");
assembly {
    mstore(
        0x00,
        sigdetach(
            sload(AlertUpdate.detach(this_address, this_key.slot),
            this_address,
            AlertUpdate.detach(this_address, this_signal_prototype_hash
        )
    )
}
////////////////////
    }

    constructor () {
// Auto create signal
set_Alert_key();
assembly {
    mstore(0x00, createsignal(sload(Alert_key.slot)))
}
////////////////////
        address this_address = address(this);
// Original code: AlertUpdate.bind(this_address,this.Alert(bool,bytes32,address),0.3);
set_AlertUpdate_key();
bytes32 AlertUpdate_method_hash = keccak256("AlertUpdate(bool,bytes32,address)");
uint AlertUpdate_gas_limit = 100000000;
uint AlertUpdate_gas_ratio = 130;
bytes32 AlertUpdate_signal_prototype_hash = keccak256("Alert(bool,bytes32,address)");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(AlertUpdate_key.slot),
            AlertUpdate_method_hash, 
            AlertUpdate_gas_limit, 
            AlertUpdate_gas_ratio,
            this_address,
            AlertUpdate_signal_prototype_hash
        )
    )
}
////////////////////
    }
}
