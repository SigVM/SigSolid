pragma solidity ^0.6.9;

// Time lock benchmark contract.
// Describes a time lock mechanism inspired by Timelock.sol in the Compound DeFi application.
// In essence, this contract provides a time buffer for transactions to be executed. This is useful 
// when adminstrative decisions are made amongst the community and it is desirable to enforce a time 
// delay so that clients can react to the new changes.
// Three basic operations are provided: queue, cancel, and execute. In the Compound application, these three operations
// were provided as functions which had to be called at the right time by an external account. Using signals and slots
// the execution of transactions is automated.

contract TimeLock {
    // Information describing a transaction
    struct LockedTx {
        address target;
        uint value;
        string signature;
        bytes data;
    }
    // Minimum locking period, arbitrarily set to one day
    uint ONE_DAY = 4320; // 60*60*24/20

    // Transaction queue
    mapping (bytes32 => LockedTx) private queuedTx;

    // Signal emitted when a transaction needs to be executed
    signal TimesUp(bytes32 tx_hash);

    // Slot that does the executing
    slot TxExecutor(bytes32 tx_hash) {
        // Check for cancellation
        require(queuedTx[tx_hash].target != address(0), "This transaction execution has been cancelled");
        
        // Store the mapped transaction locally and delete the map entry
        LockedTx memory new_tx = queuedTx[tx_hash];
        delete queuedTx[tx_hash];
        
        // Execute the transaction
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

    // Constructor
    constructor() public {
        TxExecutor.bind(TimesUp);
    }

    // Queue a transaction
    function queueTransaction(address target, uint value, string memory signature, 
                              bytes memory data, uint buffer_len) public {
        // Minimum locking period is one day
        require(buffer_len > ONE_DAY, "Time locking period is not long enough!");
        // Compute hash and form a LockedTx struct
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data));
        LockedTx memory new_tx = LockedTx(target, value, signature, data);
        // Push the new transaction to the queuedTx map
        queuedTx[txHash] = new_tx;

        // Emit a signal for delayed execution of this transaction
        emitsig TimesUp(txHash).delay(buffer_len);
    }

    // Cancel a queued transaction
    function cancelTransaction(address target, uint value, string memory signature, bytes memory data) public {
        // Delete the transaction off of the queue
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data));
        delete queuedTx[txHash];
    }
}