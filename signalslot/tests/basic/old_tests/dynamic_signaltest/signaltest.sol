pragma solidity ^0.6.9;

contract A {
	uint data;
    uint public constant ONE_HOUR = 180;
	signal priceFeedUpdate(bytes memory data);
    function emitfunc(bytes memory DataSent) public {
		emitsig priceFeedUpdate(DataSent).delay(0);
    }
}

contract B {
	A dut;
	bytes public LocalPriceSum;
    uint public constant ONE_HOUR = 180;

	slot priceReceive(bytes memory obj){
        LocalPriceSum = obj;
    }

	function bindfunc(address addrA) public {
		dut = A(addrA);
		priceReceive.bind(dut.priceFeedUpdate);
	}

    function detachfunc() public {
		priceReceive.detach(dut.priceFeedUpdate);
    }

	function getLocalPriceSum() public returns (bytes memory){
		return LocalPriceSum;
	}
}

//../../../../parse.pl signaltest.sol signaltest_parsed.sol
//../../../../../build/solc/solc --overwrite -o out --asm --bin --abi signaltest_parsed.sol
cp out/A.bin ../../../../js_tests/tb_with_dyn_sigslt/contract/A-bytecode.json
cp out/A.abi ../../../../js_tests/tb_with_dyn_sigslt/contract/A-abi.json
cp out/B.bin ../../../../js_tests/tb_with_dyn_sigslt/contract/B-bytecode.json
cp out/B.abi ../../../../js_tests/tb_with_dyn_sigslt/contract/B-abi.json
cp signaltest_parsed.sol ../../../../js_tests/tb_with_dyn_sigslt/contract/signaltest_parsed.sol

