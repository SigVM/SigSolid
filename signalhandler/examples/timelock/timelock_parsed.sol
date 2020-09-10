pragma solidity ^0.7.0;


contract TimeLock {
    struct LockedTx {
        address target;
        uint value;
        string signature;
        bytes data;
    }
    uint public constant ONE_DAY = 172800;

    mapping (bytes32 => LockedTx) private queuedTx;

// Original code: signal TimesUp(bytes32);
bytes32 private TimesUp_key;
function set_TimesUp_key() private {
    TimesUp_key = keccak256("TimesUp(bytes32)");
}
////////////////////

// Original code: handler ExecuteTx;
bytes32 private ExecuteTx_key;
function set_ExecuteTx_key() private {
    ExecuteTx_key = keccak256("ExecuteTx(bytes32)");
}
////////////////////
    function execute_tx(bytes32 tx_hash) public {
        require(queuedTx[tx_hash].target != address(0), "This transaction execution has been cancelled");
        
        LockedTx memory new_tx = queuedTx[tx_hash];
        delete queuedTx[tx_hash];
        
        bytes memory callData;
        if (bytes(new_tx.signature).length == 0) {
            callData = new_tx.data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(new_tx.signature))), new_tx.data);
        }

        (bool success, bytes memory returnData) = new_tx
            .target
            .call{value: new_tx.value} (callData);

        require(success, "Timelock::executeTransaction: Transaction execution reverted.");
    }

    function queueTransaction(address target, uint value, string memory signature, 
                              bytes memory data, uint buffer_len) public {
        require(buffer_len > ONE_DAY, "Time locking period is not long enough!");
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data));
        LockedTx memory new_tx = LockedTx(target, value, signature, data);
        queuedTx[txHash] = new_tx;

// Original code: TimesUp.emit(txHash).delay(buffer_len);
bytes memory abi_encoded_TimesUp_data = abi.encode(txHash);
// This length is measured in bytes and is always a multiple of 32.
uint abi_encoded_TimesUp_length = abi_encoded_TimesUp_data.length;
assembly {
    mstore(
        0x00,
        sigemit(
            sload(TimesUp_key.slot), 
            abi_encoded_TimesUp_data,
            abi_encoded_TimesUp_length,
            buffer_len
        )
    )
}
////////////////////
    }

    function cancelTransaction(address target, uint value, string memory signature, bytes memory data) public {
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data));
        delete queuedTx[txHash];
    }

    constructor() {
// Original code: TimesUp.create_signal();
set_TimesUp_key();
assembly {
    mstore(0x00, createsignal(sload(TimesUp_key.slot)))
}
////////////////////
// Original code: ExecuteTx.create_handler("execute_tx(bytes32)",100000000,120);
set_ExecuteTx_key();
bytes32 ExecuteTx_method_hash = keccak256("execute_tx(bytes32)");
uint ExecuteTx_gas_limit = 100000000;
uint ExecuteTx_gas_ratio = 120;
assembly {
    mstore(
        0x00, 
        createhandler(
            sload(ExecuteTx_key.slot), 
            ExecuteTx_method_hash, 
            ExecuteTx_gas_limit, 
            ExecuteTx_gas_ratio
        )
    )
}
////////////////////
        address this_address = address(this);
// Original code: ExecuteTx.bind(this_address,"TimesUp(bytes32)");
bytes32 ExecuteTx_signal_prototype_hash = keccak256("TimesUp(bytes32)");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(ExecuteTx_key.slot),
            this_address,
            ExecuteTx_signal_prototype_hash
        )
    )
}
////////////////////
    }
}