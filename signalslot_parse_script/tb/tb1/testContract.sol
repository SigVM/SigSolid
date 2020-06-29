pragma solidity ^0.6.9;
contract newtestContract {
	signal PriceFeedUpdate(bytes32 data);
	uint x;uint y;
	constructor() public {
		PriceFeedUpdate();
	}
}
contract testContract {
	newtestContract dut;
	bytes32 price_xyz;
	uint public constant ONE_HOUR = 180; // 3600/20
	slot what_ever(bytes32 obj){
		{{}{}{}{price_xyz = obj;}}
		{{}{}{}{price_xyz = obj;}}
		{{}{}{}{price_xyz = obj;}}
		{{}{}{}{price_xyz = obj;}}{
	}}
	function bindfunc() public view{
		what_ever.bind(dut.PriceFeedUpdate);
	}
    function emitfunc() public view{
		emitsig dut.PriceFeedUpdate(price_xyz).delay(ONE_HOUR);
    }
    function detachfunc() public view{
		what_ever.detach(dut.PriceFeedUpdate);
    }
	constructor() public {
		what_ever();
	}
}



