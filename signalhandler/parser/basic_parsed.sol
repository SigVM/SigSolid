pragma solidity ^0.7.0;

contract A {
// Original code: signal Alert(string,bytes32,uint);
bytes32 private Alert_key;
function set_Alert_key() private {
    Alert_key = keccak256("Alert(string,bytes32,uint)");
}
////////////////////
// Original code: handler AlertHandle;
bytes32 private AlertHandle_key;
function set_AlertHandle_key() private {
    AlertHandle_key = keccak256("AlertHandle(string,bytes32,uint)");
}
////////////////////
    string fooo;
    bytes32 barr;
    uint bazz;

    function Update(string memory foo, bytes32 bar, uint baz) public {
        fooo = foo;
        barr = bar;
        bazz = baz;
        return;
    }

    function initialize() public {
// Original code: Alert.create_signal();
set_Alert_key();
assembly {
    mstore(0x00, createsignal(sload(Alert_key.slot)))
}
////////////////////
// Original code: AlertHandle.create_handler("AlertHandleFunc(uint,string)",25,120);
set_AlertHandle_key();
bytes32 AlertHandle_method_hash = keccak256("AlertHandleFunc(uint,string)");
uint AlertHandle_gas_limit = 25;
uint AlertHandle_gas_ratio = 120;
assembly {
    mstore(
        0x00, 
        createhandler(
            sload(AlertHandle_key.slot), 
            AlertHandle_method_hash, 
            AlertHandle_gas_limit, 
            AlertHandle_gas_ratio
        )
    )
}
////////////////////
    }

    function cleanup() public {
// Original code: Alert.delete_signal();
Alert_key = 0;
assembly {
    mstore(0x00, deletesignal(sload(Alert_key.slot)))
}
////////////////////
// Original code: AlertHandle.delete_handler();
AlertHandle_key = 0;
assembly {
    mstore(0x00, deletehandler(sload(AlertHandle_key.slot)))
}
////////////////////
    }

    function binding() public view {
        address this_address = address(this);
// Original code: AlertHandle.bind(this_address,"Alert(string,bytes32,uint,bytes[])");
bytes32 AlertHandle_signal_prototype_hash = keccak256("Alert(string,bytes32,uint,bytes[])");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(AlertHandle_key.slot),
            this_address,
            AlertHandle_signal_prototype_hash
        )
    )
}
////////////////////
    }
    
    function emitting() public view {
        string memory foo = "foo is here";
        bytes32 bar = 0;
        uint baz = 2;
// Original code: Alert.emit(foo,bar,baz).delay(5);
bytes memory abi_encoded_Alert_data = abi.encode(foo,bar,baz);
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
// Original code: AlertHandle.detach(0x4324,"Alert(string,bytes32,uint,bytes[])");
bytes32 AlertHandle_signal_prototype_hash = keccak256("Alert(string,bytes32,uint,bytes[])");
assembly {
    mstore(
        0x00,
        sigdetach(
            sload(AlertHandle_key.slot),
            0x4324,
            AlertHandle_signal_prototype_hash
        )
    )
}
////////////////////
    }
}