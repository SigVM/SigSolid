pragma solidity ^0.6.9;
contract B {
	bytes32 public LocalPriceSum;
    uint public priceReceive_status;
    bytes32 public priceReceive_codePtr;//codePtr is useless now
    bytes32 public priceReceive_key;
    function priceReceive() public{
        priceReceive_key = keccak256("function priceReceive_func(bytes32 obj)");
        assembly {
            sstore(priceReceive_status_slot,createslot(32,1,2,sload(priceReceive_key_slot)))
        }		
    }
    function priceReceive_func(bytes32 obj) public{
        LocalPriceSum = LocalPriceSum | obj;
    }
	constructor() public {
		priceReceive();
	}
}