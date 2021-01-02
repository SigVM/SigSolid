pragma solidity ^0.7.0;

// Very simple usage of signals and handlers to demonstrate what the parser does.
contract A {
    signal Alert(bool, bytes32, address);
    bool fooo;
    bytes32 barr;
    address bazz;

    function AlertUpdate(bool foo, bytes32 bar, address baz) handler {
        fooo = foo;
        barr = bar;
        bazz = baz;
        return;
    }

    function cleanup() public {
        Alert.delete_signal();
        AlertUpdate.delete_handler();
    }

    function binding() public {
        address this_address = address(this);
        AlertUpdate.bind(this_address, "Alert(bool,bytes32,address)", 0.46);
    }
    
    function emitting(address data3) public view {
        bool xfoo = true;
        bytes32 xbar = 0;
        address xbaz = data3;
        Alert.emit(xfoo, xbar, xbaz).delay(5);
    }

    function detaching() public view {
        address this_address = address(this);
        AlertUpdate.detach(this_address, "Alert(bool,bytes32,address)");
    }

    constructor () {
        address this_address = address(this);
        AlertUpdate.bind(this_address, "Alert(bool,bytes32,address)", 0.3);
    }
}
