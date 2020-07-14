pragma solidity ^0.6.9;
contract B {
	bytes32 public LocalPriceSum;
	slot priceReceive(bytes32 obj){
        LocalPriceSum = LocalPriceSum | obj;
    }
	constructor() public {
		priceReceive();
	}
}