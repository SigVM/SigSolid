pragma solidity ^0.7.0;

contract SelfAlerter {
// Original code: signal BigAlert(string,uint8[5],uint32);
bytes32 private BigAlert_key;
function set_BigAlert_key() private {
    BigAlert_key = keccak256("BigAlert(string,uint8[5],uint32)");
}
////////////////////
// Original code: handler BigHandler;
bytes32 private BigHandler_key;
function set_BigHandler_key() private {
    BigHandler_key = keccak256("BigHandler(string,uint8[5],uint32)");
}
////////////////////
    string fooo;
    uint8[] barr;
    uint32 bazz;
    function update(string calldata foo, uint8[5] calldata bar, uint32 baz) public {
        fooo = foo;
        barr = bar;
        bazz = baz;
        return;
    }
    function signal_emit() public view {
        string memory foo = "Hello World!";
        uint8[5] memory bar = ([1, 1, 2, 2, 4]);
        uint32 baz = 42;
// Original code: BigAlert.emit(foo,bar,baz).delay(1);
bytes memory abi_encoded_BigAlert_data = abi.encode(foo,bar,baz);
// This length is measured in bytes and is always a multiple of 32.
uint abi_encoded_BigAlert_length = abi_encoded_BigAlert_data.length;
assembly {
    mstore(
        0x00,
        sigemit(
            sload(BigAlert_key.slot), 
            abi_encoded_BigAlert_data,
            abi_encoded_BigAlert_length,
            1
        )
    )
}
////////////////////
    }
    constructor() {
// Original code: BigAlert.create_signal();
set_BigAlert_key();
assembly {
    mstore(0x00, createsignal(sload(BigAlert_key.slot)))
}
////////////////////
// Original code: BigHandler.create_handler("update(string,uint8[5],uint32)",1000000,120);
set_BigHandler_key();
bytes32 BigHandler_method_hash = keccak256("update(string,uint8[5],uint32)");
uint BigHandler_gas_limit = 1000000;
uint BigHandler_gas_ratio = 120;
assembly {
    mstore(
        0x00, 
        createhandler(
            sload(BigHandler_key.slot), 
            BigHandler_method_hash, 
            BigHandler_gas_limit, 
            BigHandler_gas_ratio
        )
    )
}
////////////////////
        address this_address = address(this);
// Original code: BigHandler.bind(this_address,"BigAlert(string,uint8[5],uint32)");
bytes32 BigHandler_signal_prototype_hash = keccak256("BigAlert(string,uint8[5],uint32)");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(BigHandler_key.slot),
            this_address,
            BigHandler_signal_prototype_hash
        )
    )
}
////////////////////
    }
}