pragma solidity ^0.6.9;

contract A {
	uint data;
    uint public constant ONE_HOUR = 180;
	signal priceFeedUpdate(bytes32 data);
	signal random();

    function emitfunc(bytes32 DataSent) public {
		emitsig priceFeedUpdate(DataSent).delay(ONE_HOUR);
    }
}

contract B {
	A dut;
	bytes32 public LocalPriceSum;
    uint public constant ONE_HOUR = 180;

	slot priceReceive(bytes32 obj){
        LocalPriceSum = LocalPriceSum | obj;
    }

	function bindfunc() public view {
		priceReceive.bind(dut.priceFeedUpdate);
	}

    function detachfunc() public view {
		priceReceive.detach(dut.priceFeedUpdate);
    }
}