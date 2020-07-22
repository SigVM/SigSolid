pragma solidity ^0.6.9;


contract TimeLock {
    
    struct LockedTx {
        address target;
        uint value;
        string signature;
        bytes data;
    }
    
    uint ONE_DAY = 4320; 

    
    mapping (bytes32 => LockedTx[]) queuedTx;

    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // GENERATED BY SIGNALSLOT PARSER
    
    // Original Code:
    // signal TimesUp;

    // TODO: Arguments should not be limited to one 32 byte value

    // Generated variables that represent the signal
	bytes32 private TimesUp_data;
	bytes private TimesUp_dataslot;
	uint private TimesUp_status;
    bytes32 private TimesUp_key;

    // Set the data to be emitted
	function set_TimesUp_data(bytes32 dataSet) private {
       TimesUp_data = dataSet;
    }

    // Get the argument count
	function get_TimesUp_argc() public pure returns (uint argc) {
       return 32;
    }

    // Get the signal key
	function get_TimesUp_key() public view returns (bytes32 key) {
       return TimesUp_key;
    }

    // Get the data slot
    function get_TimesUp_dataslot() public view returns (bytes memory dataslot) {
       return TimesUp_dataslot;
    }

    // signal TimesUp construction
    // This should be called once in the contract construction.
    // This parser should automatically call it.
    function TimesUp() private {
        TimesUp_key = keccak256("function TimesUp()");
		assembly {
			sstore(TimesUp_status_slot, createsig(32, sload(TimesUp_key_slot)))
			sstore(TimesUp_dataslot_slot, TimesUp_data_slot)
		}
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////


    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // GENERATED BY SIGNALSLOT PARSER

    // Original Code:
    // slot TxExecutor {...}

    // Generated variables that represent the slot
    uint private TxExecutor_status;
    bytes32 private TxExecutor_key;

    // Get the signal key
	function get_TxExecutor_key() public view returns (bytes32 key) {
       return TxExecutor_key;
    }

    // TxExecutor construction
    // Should be called once in the contract construction
    function TxExecutor() private {
        TxExecutor_key = keccak256("TxExecutor_func(bytes32)");
        assembly {
            sstore(TxExecutor_status_slot, createslot(32, 10, 30000, sload(TxExecutor_key_slot)))
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // TxExecutor code to be executed
    // The slot is converted to a function that will be called in slot transactions.
    function TxExecutor_func(bytes32 tx_hash) public {
        
        require(queuedTx[tx_hash] != 0, "This transaction execution has been cancelled");
        
        
        LockedTx new_tx = queuedTx[tx_hash];
        delete queuedTx[tx_hash];
        
        
        bytes memory callData;
        if (bytes(new_tx.signature).length == 0) {
            callData = new_tx.data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(new_tx.signature))), new_tx.data);
        }

        
        (bool success, bytes memory returnData) = new_tx.target.call.value(new_tx.value)(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");
    }

    
    constructor() public {
   TimesUp();
   TxExecutor();
        //////////////////////////////////////////////////////////////////////////////////////////////////
        // GENERATED BY SIGNALSLOT PARSER

        // Original Code:
        // TxExecutor.bind(this.TimesUp)

        // Convert to address
		address this_bindslot_address = address(this);
        // Get signal key from emitter contract
		bytes32 this_bindslot_TimesUp_key = get_TimesUp_key();
        // Get slot key from receiver contract
        bytes32 this_bindslot_TxExecutor_key = get_TxExecutor_key();
        // Use assembly to bind slot to signal
		assembly {
			mstore(0x40, bindslot(this_bindslot_address, this_bindslot_TimesUp_key, this_bindslot_TxExecutor_key))
	    }
        //////////////////////////////////////////////////////////////////////////////////////////////////

    }

    
    function queueTransaction(address target, uint value, string memory signature, 
                              bytes memory data, uint buffer_len) public {
        
        require(buffer_len > ONE_DAY, "Time locking period is not long enough!");
        
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data));
        LockedTx new_tx = LockedTx(target, value, signature, data);
        
        queuedTx[txHash] = new_tx;

        
        //////////////////////////////////////////////////////////////////////////////////////////////////
        // GENERATED BY SIGNALSLOT PARSER
        
        // Original Code:
        // emitsig TimesUp(txHash).delay(buffer_len)

        // Set the data field in the signal
        set_TimesUp_data(txHash);
        // Get the argument count
        uint this_emitsig_TimesUp_argc = get_TimesUp_argc();
        // Get the data slot
		bytes memory this_emitsig_TimesUp_dataslot = get_TimesUp_dataslot();
        // Get the signal key
		bytes32 this_emitsig_TimesUp_key = get_TimesUp_key();
        // Use assembly to emit the signal and queue up slot transactions
		assembly {
			mstore(0x40, emitsig(this_emitsig_TimesUp_key, buffer_len, this_emitsig_TimesUp_dataslot, this_emitsig_TimesUp_argc))
	    }
        //////////////////////////////////////////////////////////////////////////////////////////////////

    }

    
    function cancelTransaction(address target, uint value, string memory signature, bytes memory data) public {
        
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data));
        delete queuedTx[txHash];
    }
}
