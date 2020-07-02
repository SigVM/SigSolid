pragma solidity ^0.6.9;
contract newtestContract {
	bytes32 public PriceFeedUpdate_data;
	bytes public PriceFeedUpdate_dataslot;
	uint public PriceFeedUpdate_status;
    bytes32 public PriceFeedUpdate_key;
	
    function PriceFeedUpdate() public{
        PriceFeedUpdate_key = keccak256("function PriceFeedUpdate()");
		assembly {
			sstore(PriceFeedUpdate_status_slot,createsig(32, sload(PriceFeedUpdate_key_slot)))
			mstore(PriceFeedUpdate_dataslot_slot,PriceFeedUpdate_data_slot)
		}
    }

	uint x;uint y;
	constructor() public {
		PriceFeedUpdate();
	}
}
contract testContract {
	newtestContract dut;
	bytes32 price_xyz;
	uint public constant ONE_HOUR = 10;
    uint public what_ever_status;
    bytes32 public what_ever_codePtr;
    function what_ever() public{
        what_ever_codePtr = keccak256("what_ever_func(bytes32 obj)");
        assembly {
            sstore(what_ever_status_slot,createslot(32,1,100,0x09,sload(what_ever_codePtr_slot)))
        }		
    }
    function what_ever_func(bytes32 obj) public{
		price_xyz = obj;
	}
	function bindfunc() public {
		address dut_address = address(dut);
		bytes32 dut_PriceFeedUpdate_key = dut.PriceFeedUpdate_key();
		assembly {
			bindsig(dut_address,dut_PriceFeedUpdate_key,sload(what_ever_codePtr_slot))
	    }
	}
    function emitfunc() public {
		bytes memory dut_PriceFeedUpdate_dataslot = dut.PriceFeedUpdate_dataslot();
		bytes32 dut_PriceFeedUpdate_key = dut.PriceFeedUpdate_key();
		assembly {
			mstore(dut_PriceFeedUpdate_dataslot,mload(price_xyz_slot))
			emitsig(dut_PriceFeedUpdate_key,ONE_HOUR,dut_PriceFeedUpdate_dataslot,32)
	    }

    }
    function detachfunc() public {
		bytes32 dut_PriceFeedUpdate_key = dut.PriceFeedUpdate_key();
		address dut_address = address(dut);
		assembly{
			detachsig(dut_address,dut_PriceFeedUpdate_key,sload(what_ever_codePtr_slot))
		}

    }
	constructor() public {
		what_ever();
	}
}



