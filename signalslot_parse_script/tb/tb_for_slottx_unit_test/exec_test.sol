pragma solidity ^0.6.9;
contract B {
	bytes3 public LocalPriceSum;
	slot priceReceive(bytes3 obj){
        LocalPriceSum = LocalPriceSum | obj;
    }
	constructor() public {
		priceReceive();
	}
}