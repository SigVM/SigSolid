pragma solidity ^0.6.9;

// Delayed price feed benchmark contract.
// Describes a price update system using signals and slots.
// Contracts A, and B all automatically update their prices when the
// price oracle receives something on its external feed.
// This is inspired by MakerDAO's osm.sol source file.

// Contract acts as a one hour buffer for information from an oracle to reach receivers
contract PriceOracleBuffer {
    // Number of block generation cycles between price updates
    uint public constant ONE_HOUR_CONFLUX = 7200; // 3600/20
    // Price feeds
    uint cur;
    uint nxt;
    // Pseudo price feed. In a real production contract this would peek into
    // an external oracle.
    uint peeked_data;

    // Price update signal
    signal PriceFeedUpdate(uint price);

    // Function that queries the new price and sends an update signal
    slot SendUpdate(uint unused) {
        peeked_data = peeked_data + 1;
        cur = nxt;
        nxt = peeked_data;
        emitsig PriceFeedUpdate(cur).delay(ONE_HOUR_CONFLUX);
    }

    // Constructor
    constructor() public {
        // Bind SendUpdate slot to the signal PriceFeedUpdate. This way the price feed is automatically
        // updated every single hour. Feed is also then relayed to other receivers.
        peeked_data = 0;
        SendUpdate.bind(PriceFeedUpdate);
        emitsig PriceFeedUpdate(0).delay(0);
    }
}

// Both contracts RecieverA and RecieverB are listening for the new price
contract ReceiverA {
    // Address of PriceOracle
    PriceOracleBuffer public oracle;
    // Price
    uint price;

    slot RecievePrice(uint new_price) {
        price = new_price;
    }

    constructor(address oracle_addr) public {
        oracle = PriceOracleBuffer(oracle_addr);
        RecievePrice.bind(oracle.PriceFeedUpdate);
    }
    
    function detach() public {
        RecievePrice.detach(oracle.PriceFeedUpdate);
    }
}

// Identical to contract A. Should recieve the same price update.
contract ReceiverB {
    // Address of PriceOracle
    PriceOracleBuffer public oracle;
    // Price
    uint price;

    slot RecievePrice(uint new_price) {
        price = new_price;
    }

    constructor(address oracle_addr) public {
        oracle = PriceOracleBuffer(oracle_addr);
        RecievePrice.bind(oracle.PriceFeedUpdate);
    }
    
    function detach() public {
        RecievePrice.detach(oracle.PriceFeedUpdate);
    }
}
