pragma solidity ^0.6.9;
contract A {
    uint public constant ONE_HOUR = 180;
	bytes32 public priceFeedUpdate_data;
	bytes public priceFeedUpdate_dataslot;
	uint public priceFeedUpdate_status;
    bytes32 public priceFeedUpdate_key;
	function set_priceFeedUpdate_data(bytes32 dataSet) public {
       priceFeedUpdate_data = dataSet;
    }
	function get_priceFeedUpdate_argc() public pure returns (uint argc){
       return 32;
    }
	function get_priceFeedUpdate_key() public view returns (bytes32 key){
       return priceFeedUpdate_key;
    }
    function get_priceFeedUpdate_dataslot() public view returns (bytes memory dataslot){
       return priceFeedUpdate_dataslot;
    }
    function priceFeedUpdate() public{
        priceFeedUpdate_key = keccak256("function priceFeedUpdate()");
		assembly {
			sstore(priceFeedUpdate_status_slot, createsig(32, sload(priceFeedUpdate_key_slot)))
			sstore(priceFeedUpdate_dataslot_slot, priceFeedUpdate_data_slot)
		}
    }

    function emitfunc(bytes32 DataSent) public {
        this.set_priceFeedUpdate_data(DataSent);
        uint this_priceFeedUpdate_argc = this.get_priceFeedUpdate_argc();
		bytes memory this_priceFeedUpdate_dataslot = this.get_priceFeedUpdate_dataslot();
		bytes32 this_priceFeedUpdate_key = this.get_priceFeedUpdate_key();
		assembly {
			mstore(0x40, emitsig(this_priceFeedUpdate_key, ONE_HOUR, this_priceFeedUpdate_dataslot, this_priceFeedUpdate_argc))
	    }

    }

constructor() public {
   priceFeedUpdate();
}
}
contract B {
	A dut;
	bytes32 public LocalPriceSum;
    uint public constant ONE_HOUR = 180;
    uint public priceReceive_status;
    bytes32 public priceReceive_key;
    function priceReceive() public{
        priceReceive_key = keccak256("priceReceive_func(bytes32)");
        assembly {
            sstore(priceReceive_status_slot, createslot(32, 10, 30000, sload(priceReceive_key_slot)))
        }		
    }
    function priceReceive_func(bytes32 obj) public{
        LocalPriceSum = LocalPriceSum | obj;
    }
	function bindfunc() public view {
		address dut_address = address(dut);
		bytes32 dut_priceFeedUpdate_key = dut.get_priceFeedUpdate_key();
		assembly {
			mstore(0x40,bindslot(dut_address,dut_priceFeedUpdate_key,sload(priceReceive_key_slot)))
	    }

	}
    function detachfunc() public view {
		bytes32 dut_priceFeedUpdate_key = dut.get_priceFeedUpdate_key();
		address dut_address = address(dut);
		assembly{
			mstore(0x40, detachslot(dut_address, dut_priceFeedUpdate_key, sload(priceReceive_key_slot)))
		}

    }
constructor() public {
   priceReceive();
}
}