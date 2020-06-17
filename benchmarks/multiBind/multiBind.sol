struct DataCollected{
	uint Confirmed;
	uint Deaths;
	uint Recovered;
	uint Active;
	bool DataValid;
}

struct Package{
	DataCollected Data;
    uint CountryCode;
	mapping(address => int) public Receivers;
	int GasRequired;
	address payable public Hoster;
}

contract DataSender{
	Package P0;
    Package P1;
	signal EmitedData0(Package Package_);
    signal EmitedData1(Package Package_);
	function update(uint a,uint b, uint c,uint d, uint code) {
        if(code == 0){
            P0.Data.Confirmed = a;
            P0.Data.Deaths = b;
            P0.Data.Recovered = c;
            P0.Data.Active = d;
            P0.Data.DataValid = true;
        }else{
            P1.Data.Confirmed = a;
            P1.Data.Deaths = b;
            P1.Data.Recovered = c;
            P1.Data.Active = d;
            P1.Data.DataValid = true;
        }
	}

	function sendData(int GasRequired_) payable {
		Package EmitedP0 = P0;
        for (
            uint i = P0.Receivers.iterate_start();
            P0.Receivers.iterate_valid(i);
            i = P0.Receivers.iterate_next(i)
        ) {
            (address addr,) = P0.Receivers.iterate_get(i);
            P0.Receivers[addr] -= GasRequired;

        }
		P0.GasRequired = GasRequired_;
		EmitedP0.GasRequired = GasRequired_;
		emit EmitedData0(EmitedP0);

		Package EmitedP1 = P1;
        for (
            uint i = P1.Receivers.iterate_start();
            P1.Receivers.iterate_valid(i);
            i = P1.Receivers.iterate_next(i)
        ) {
            (address addr,) = P1.Receivers.iterate_get(i);
            P1.Receivers[addr] -= GasRequired;

        }
		P1.GasRequired = GasRequired_;
		EmitedP1.GasRequired = GasRequired_;
		emit EmitedData1(EmitedP1);
	}

	function userUpdate(int balance, uint code) public{
        if(code == 0)
		    P0.Receivers[msg.sender] = balance;
        else
            P1.Receivers[msg.sender] = balance;
	}

	function userDelete() public{
		delete P0.Receivers[msg.sender];
        delete P1.Receivers[msg.sender];
	}

	constructor() {
		P0.Data.DataValid = false;
		P0.Hoster = address(this);
        P0.CountryCode = 0;
        P1.Data.DataValid = false;
		P1.Hoster = address(this);
        P1.CountryCode = 1;
	}

}

contract DataReceiver is DataSender{
	DataCollected public LocalDC0;
    DataCollected public LocalDC1;
    slot Recv0(Package P_) {
		this.payGas(P_);
		LocalDC.Confirmed = P_.Data.Confirmed;
		LocalDC.Deaths = P_.Data.Deaths;
		LocalDC.Recovered = P_.Data.Recovered;
		LocalDC.Active = P_.Data.Active;
    }
    slot Recv1(Package P_) {
		this.payGas(P_);
		LocalDC.Confirmed = P_.Data.Confirmed;
		LocalDC.Deaths = P_.Data.Deaths;
		LocalDC.Recovered = P_.Data.Recovered;
		LocalDC.Active = P_.Data.Active;
    }

	function payGas(Package Pk_) public payable {
		require(Pk_.Receivers[address(this)] >= Pk_.GasRequired);
		Pk_.Hoster.transfer(Pk_.GasRequired);
	}

	function getData() returns (DataCollected DC){
		return (DC0,DC1);
	}

	constructor() {
		LocalDC0.DataValid = false;
        LocalDC1.DataValid = false;
		Recv0.bind(EmitedData0);
        Recv1.bind(EmitedData1);
	}
}
