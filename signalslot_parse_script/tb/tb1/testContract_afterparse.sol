pragma solidity ^0.6.9;
contract newtestContract {
	uint public PriceFeedUpdate_data;
	bytes public PriceFeedUpdate_dataslot;
	uint public PriceFeedUpdate_sigId;
    bytes4 public PriceFeedUpdate_key;
	
    function PriceFeedUpdate() public{
        PriceFeedUpdate_key = keccak256("function PriceFeedUpdate()")[0];
		assembly {
			sstore(PriceFeedUpdate_sigId_slot,createsig(extcodesize(PriceFeedUpdate_data_slot),sload(PriceFeedUpdate_key_slot)))
			mstore(PriceFeedUpdate_dataslot_slot,PriceFeedUpdate_data_slot)
		}
    }

	uint x;uint y;
	constructor() public {
		{PriceFeedUpdate();}
	}
}
contract testContract {
	newtestContract dut;
	uint price_xyz;
	uint public constant ONE_HOUR = 180; // 3600/20
    uint public what_ever_slotId;
    bytes4 public what_ever_codePtr;
    function what_ever() public{
        what_ever_codePtr = keccak256("what_ever_func(uint obj)")[0];
        assembly {
            sstore(what_ever_slotId_slot,createslot(8,sload(what_ever_codePtr_slot),1,2))
        }		
    }
    function what_ever_func(uint obj) public{
		{{}{}{}{price_xyz = obj;}}
		{{}{}{}{price_xyz = obj;}}
		{{}{}{}{price_xyz = obj;}}
		{{}{}{}{price_xyz = obj;}}{
	}}
	function bindfunc() public view{
		address dut_address = address(dut);
		uint dut_PriceFeedUpdate_sigId = dut.PriceFeedUpdate_sigId();
		assembly {
			bindsig(dut_address,dut_PriceFeedUpdate_sigId,sload(what_ever_slotId_slot))
	    }

	}
    function emitfunc() public view{
		bytes memory dut_PriceFeedUpdate_dataslot = dut.PriceFeedUpdate_dataslot();
		uint dut_PriceFeedUpdate_sigId = dut.PriceFeedUpdate_sigId();
		assembly {
			mstore(dut_PriceFeedUpdate_dataslot,mload(price_xyz_slot))
			emitsig(dut_PriceFeedUpdate_sigId,ONE_HOUR,dut_PriceFeedUpdate_dataslot,1)
	    }

    }
    function detachfunc() public view{
		uint dut_PriceFeedUpdate_sigId = dut.PriceFeedUpdate_sigId();
		address dut_address = address(dut);
		assembly{
			detachsig(dut_address,dut_PriceFeedUpdate_sigId,sload(what_ever_slotId_slot))
		}

    }
}



