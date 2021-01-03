pragma solidity ^0.7.0;

// Very simple usage of signals and handlers to demonstrate what the parser does.
contract A {
    signal Alert1(bool, bytes32, address);
    signal Alert2(bool, bytes32, address);
    bool fooo;
    bytes32 barr;
    address bazz;

    function AlertUpdate(bool foo, bytes32 bar, address baz) handler {
        fooo = foo;
        barr = bar;
        bazz = baz;
        return;
    }
    function AdvAlertUpdate(bool foo, bytes32 bar, address baz) handler {
        fooo = !foo;
        barr = ~bar;
        bazz = address(this);
        return;
    }

    function cleanup() public {
        Alert1.delete_signal();
        Alert2.delete_signal();
    }

    function binding() public {
        address this_address = address(this);
        AlertUpdate.bind(this_address, this_address.Alert1(bool,bytes32,address), 0.46);
    }
    
    function emitting(address data3) public view {
        bool xfoo = true;
        bytes32 xbar = 0;
        address xbaz = data3;
        Alert1.emit(xfoo, xbar, xbaz).delay(5);
        Alert2.emit(xfoo, xbar, xbaz).delay(15);
    }

    function detaching() public view {
        address this_address = address(this);
        AlertUpdate.detach(this_address, anything.Alert1(bool,bytes32,address));
    }

    constructor () {
        address this_address = address(this);
        AlertUpdate.bind(this_address, idontknow.Alert1(bool,bytes32,address), 0.3);
        AdvAlertUpdate.bind(this_address, this_address.Alert2(bool,bytes32,address), 0.78);
    }
}
