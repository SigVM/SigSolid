pragma solidity ^0.7.0;

// Very simple usage of signals and handlers to demonstrate what the parser does.
contract A {
    signal Alert(string, bytes32, uint);
    handler AlertHandle(string, bytes32, uint);
    string fooo;
    bytes32 barr;
    uint bazz;

    function Update(string memory foo, bytes32 bar, uint baz) public {
        fooo = foo;
        barr = bar;
        bazz = baz;
        return;
    }

    function initialize() public {
        Alert.create_signal();
        AlertHandle.create_handler("AlertHandleFunc(uint,string)", 25, 120);
    }

    function cleanup() public {
        Alert.delete_signal();
        AlertHandle.delete_handler();public
    }

    function binding() public view {
        address this_address = address(this);
        AlertHandle.bind(this_address, "Alert(string,bytes32,uint,bytes[])");
    }
    
    function emitting() public view {
        string memory foo = "foo is here";
        bytes32 bar = 0;
        uint baz = 2;
        Alert.emit(foo, bar, baz).delay(5);
    }

    function detaching() public view {
        AlertHandle.detach(0x4324, "Alert(string,bytes32,uint,bytes[])");
    }
}