pragma solidity ^0.7.0;

contract PriceOracleBuffer {
    uint256 public constant ONE_HOUR_CONFLUX = 7200;
    uint256 ready;
    uint256 wait;
    uint256 pseudo_oracle;

// Original code: signal PriceFeedUpdate(uint256);
bytes32 private PriceFeedUpdate_key;
function set_PriceFeedUpdate_key() private {
    PriceFeedUpdate_key = keccak256("PriceFeedUpdate(uint256)");
}
////////////////////

// Original code: handler UpdateHandler;
bytes32 private UpdateHandler_key;
function set_UpdateHandler_key() private {
    UpdateHandler_key = keccak256("UpdateHandler(uint256)");
}
////////////////////
    
    function handle_update(uint256 /* unused */) public {
        pseudo_oracle = pseudo_oracle + 1;
        ready = wait;
        wait = pseudo_oracle;
// Original code: PriceFeedUpdate.emit(ready).delay(ONE_HOUR_CONFLUX);
bytes memory abi_encoded_PriceFeedUpdate_data = abi.encode(ready);
// This length is measured in bytes and is always a multiple of 32.
uint abi_encoded_PriceFeedUpdate_length = abi_encoded_PriceFeedUpdate_data.length;
assembly {
    mstore(
        0x00,
        sigemit(
            sload(PriceFeedUpdate_key.slot), 
            abi_encoded_PriceFeedUpdate_data,
            abi_encoded_PriceFeedUpdate_length,
            ONE_HOUR_CONFLUX
        )
    )
}
////////////////////
    }

    constructor() {
        address this_address = address(this);
// Original code: UpdateHandler.create_handler("handle_update(uint256)",1000000,120);
set_UpdateHandler_key();
bytes32 UpdateHandler_method_hash = keccak256("handle_update(uint256)");
uint UpdateHandler_gas_limit = 1000000;
uint UpdateHandler_gas_ratio = 120;
assembly {
    mstore(
        0x00, 
        createhandler(
            sload(UpdateHandler_key.slot), 
            UpdateHandler_method_hash, 
            UpdateHandler_gas_limit, 
            UpdateHandler_gas_ratio
        )
    )
}
////////////////////
// Original code: PriceFeedUpdate.create_signal();
set_PriceFeedUpdate_key();
assembly {
    mstore(0x00, createsignal(sload(PriceFeedUpdate_key.slot)))
}
////////////////////
// Original code: UpdateHandler.bind(this_address,"PriceFeedUpdate(uint256)");
bytes32 UpdateHandler_signal_prototype_hash = keccak256("PriceFeedUpdate(uint256)");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(UpdateHandler_key.slot),
            this_address,
            UpdateHandler_signal_prototype_hash
        )
    )
}
////////////////////
// Original code: PriceFeedUpdate.emit(0).delay(0);
bytes memory abi_encoded_PriceFeedUpdate_data = abi.encode(0);
// This length is measured in bytes and is always a multiple of 32.
uint abi_encoded_PriceFeedUpdate_length = abi_encoded_PriceFeedUpdate_data.length;
assembly {
    mstore(
        0x00,
        sigemit(
            sload(PriceFeedUpdate_key.slot), 
            abi_encoded_PriceFeedUpdate_data,
            abi_encoded_PriceFeedUpdate_length,
            0
        )
    )
}
////////////////////
        pseudo_oracle = 0;
    }
}

contract ReceiverA {
    uint256 price;
// Original code: handler ReceivePrice;
bytes32 private ReceivePrice_key;
function set_ReceivePrice_key() private {
    ReceivePrice_key = keccak256("ReceivePrice(uint256)");
}
////////////////////
    function price_feed_handle(uint256 new_price) public {
        price = new_price;
    }

    function bind_to_feed(address feed_address) public view {
// Original code: ReceivePrice.bind(feed_address,"PriceFeedUpdate(uint256)");
bytes32 ReceivePrice_signal_prototype_hash = keccak256("PriceFeedUpdate(uint256)");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(ReceivePrice_key.slot),
            feed_address,
            ReceivePrice_signal_prototype_hash
        )
    )
}
////////////////////
    }
    function detach_from_feed(address feed_address) public view {
// Original code: ReceivePrice.detach(feed_address,"PriceFeedUpdate(uint256)");
bytes32 ReceivePrice_signal_prototype_hash = keccak256("PriceFeedUpdate(uint256)");
assembly {
    mstore(
        0x00,
        sigdetach(
            sload(ReceivePrice_key.slot),
            feed_address,
            ReceivePrice_signal_prototype_hash
        )
    )
}
////////////////////
    }

    constructor() {
// Original code: ReceivePrice.create_handler("price_feed_handle(uint256)",1000000,120);
set_ReceivePrice_key();
bytes32 ReceivePrice_method_hash = keccak256("price_feed_handle(uint256)");
uint ReceivePrice_gas_limit = 1000000;
uint ReceivePrice_gas_ratio = 120;
assembly {
    mstore(
        0x00, 
        createhandler(
            sload(ReceivePrice_key.slot), 
            ReceivePrice_method_hash, 
            ReceivePrice_gas_limit, 
            ReceivePrice_gas_ratio
        )
    )
}
////////////////////
        price = 0;
    }
}
contract ReceiverB {
    uint256 price;
// Original code: handler ReceivePrice;
bytes32 private ReceivePrice_key;
function set_ReceivePrice_key() private {
    ReceivePrice_key = keccak256("ReceivePrice(uint256)");
}
////////////////////
    function price_feed_handle(uint256 new_price) public {
        price = new_price;
    }

    function bind_to_feed(address feed_address) public view {
// Original code: ReceivePrice.bind(feed_address,"PriceFeedUpdate(uint256)");
bytes32 ReceivePrice_signal_prototype_hash = keccak256("PriceFeedUpdate(uint256)");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(ReceivePrice_key.slot),
            feed_address,
            ReceivePrice_signal_prototype_hash
        )
    )
}
////////////////////
    }
    function detach_from_feed(address feed_address) public view {
// Original code: ReceivePrice.detach(feed_address,"PriceFeedUpdate(uint256)");
bytes32 ReceivePrice_signal_prototype_hash = keccak256("PriceFeedUpdate(uint256)");
assembly {
    mstore(
        0x00,
        sigdetach(
            sload(ReceivePrice_key.slot),
            feed_address,
            ReceivePrice_signal_prototype_hash
        )
    )
}
////////////////////
    }

    constructor() {
// Original code: ReceivePrice.create_handler("price_feed_handle(uint256)",1000000,120);
set_ReceivePrice_key();
bytes32 ReceivePrice_method_hash = keccak256("price_feed_handle(uint256)");
uint ReceivePrice_gas_limit = 1000000;
uint ReceivePrice_gas_ratio = 120;
assembly {
    mstore(
        0x00, 
        createhandler(
            sload(ReceivePrice_key.slot), 
            ReceivePrice_method_hash, 
            ReceivePrice_gas_limit, 
            ReceivePrice_gas_ratio
        )
    )
}
////////////////////
        price = 0;
    }
}
