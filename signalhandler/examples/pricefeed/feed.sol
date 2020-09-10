pragma solidity ^0.7.0;

// Contract acts as a one hour buffer for information from an oracle to reach receivers.
// This is inspired by MakerDAO's osm.sol source file.
contract PriceOracleBuffer {
    // Number of block generation cycles between price updates
    uint256 public constant ONE_HOUR_CONFLUX = 7200;
    // Delayed price feed
    uint256 ready;
    uint256 wait;
    // Pseudo oracle
    uint256 pseudo_oracle;

    // Price update signal
    signal PriceFeedUpdate(uint256);

    // Function that queries the new price and sends an update signal
    handler UpdateHandler(uint256); 
    
    // handler function
    function handle_update(uint256 /* unused */) public {
        pseudo_oracle = pseudo_oracle + 1;
        ready = wait;
        wait = pseudo_oracle;
        PriceFeedUpdate.emit(ready).delay(ONE_HOUR_CONFLUX);
    }

    // Constructor
    constructor() {
        address this_address = address(this);
        UpdateHandler.create_handler("handle_update(uint256)", 1000000, 120);
        PriceFeedUpdate.create_signal();
        UpdateHandler.bind(this_address, "PriceFeedUpdate(uint256)");
        PriceFeedUpdate.emit(0).delay(0);
        pseudo_oracle = 0;
    }
}

// Both contracts RecieverA and RecieverB are listening for the new price
contract ReceiverA {
    uint256 price;
    handler ReceivePrice(uint256);    
    function price_feed_handle(uint256 new_price) public {
        price = new_price;
    }

    function bind_to_feed(address feed_address) public view {
        ReceivePrice.bind(feed_address, "PriceFeedUpdate(uint256)");
    }
    function detach_from_feed(address feed_address) public view {
        ReceivePrice.detach(feed_address, "PriceFeedUpdate(uint256)");
    }

    constructor() {
        ReceivePrice.create_handler("price_feed_handle(uint256)", 1000000, 120);
        price = 0;
    }
}
contract ReceiverB {
    uint256 price;
    handler ReceivePrice(uint256);    
    function price_feed_handle(uint256 new_price) public {
        price = new_price;
    }

    function bind_to_feed(address feed_address) public view {
        ReceivePrice.bind(feed_address, "PriceFeedUpdate(uint256)");
    }
    function detach_from_feed(address feed_address) public view {
        ReceivePrice.detach(feed_address, "PriceFeedUpdate(uint256)");
    }

    constructor() {
        ReceivePrice.create_handler("price_feed_handle(uint256)", 1000000, 120);
        price = 0;
    }
}
