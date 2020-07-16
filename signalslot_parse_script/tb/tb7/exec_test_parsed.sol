pragma solidity ^0.6.9;
contract B {
	bytes3 public LocalPriceSum;
    uint public priceReceive_status;
    bytes32 public priceReceive_codePtr;//codePtr is useless now
    bytes32 public priceReceive_key;
    function priceReceive() public{
        priceReceive_key = keccak256("priceReceive_func(bytes3)");
        assembly {
            sstore(priceReceive_status_slot,createslot(3,10,30000,sload(priceReceive_key_slot)))
        }		
    }
    function priceReceive_func(bytes3 obj) public{
        LocalPriceSum = LocalPriceSum | obj;
    }
	constructor() public {
		priceReceive();
	}
}