pragma solidity ^0.6.9;

// Simple heartbeat 'contract' utilizing delayed 'signal' emit

// TODO: Parser does not support emitting signals inside slots!

contract HeartBeat {
    uint32 counter;

    signal Heart();
    slot Beat() {
        counter = counter + 1;
        emitsig Heart().delay(10);
    }

    constructor() public {
        counter = 0;
        Beat.bind(this.Heart);
        emitsig Heart().delay(10);
    }
}