pragma solidity ^0.6.9;
contract A {
    uint public constant ONE_HOUR = 180;
	signal priceFeedUpdate(bytes32 data);
    function emitfunc() public {
		emitsig priceFeedUpdate().delay(ONE_HOUR);
    }
	constructor() public {
		priceFeedUpdate();
	}
}
contract B {
	A dut;
	bytes32 public LocalPriceSum;
    uint public constant ONE_HOUR = 180;
	slot priceReceive(){
        LocalPriceSum = ~LocalPriceSum;
    }
	function bindfunc() public view {
		priceReceive.bind(dut.priceFeedUpdate);
	}
    function detachfunc() public view {
		priceReceive.detach(dut.priceFeedUpdate);
    }
	constructor() public {
		priceReceive();
	}
}