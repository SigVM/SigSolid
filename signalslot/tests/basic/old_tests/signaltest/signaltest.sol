pragma solidity ^0.6.9;

contract A {
	uint data;
    uint public constant ONE_HOUR = 180;
	signal priceFeedUpdate(bytes3 data);
	signal random();

    function emitfunc(bytes3 DataSent) public {
		emitsig priceFeedUpdate(DataSent).delay(0);
    }
}

contract B {
	A dut;
	bytes3 public LocalPriceSum;
    uint public constant ONE_HOUR = 180;

	slot priceReceive(bytes3 obj){
        LocalPriceSum = ~obj;
    }

	function bindfunc(address addrA) public {
		dut = A(addrA);
		priceReceive.bind(dut.priceFeedUpdate);
	}

    function detachfunc() public {
		priceReceive.detach(dut.priceFeedUpdate);
    }

	function getLocalPriceSum() public returns (bytes3){
		return LocalPriceSum;
	}
}
