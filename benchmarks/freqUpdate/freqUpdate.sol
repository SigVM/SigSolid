struct DataCollected{
	uint Confirmed;
	uint Deaths;
	uint Recovered;
	uint Active;
	bool DataValid;
}

struct Package{
	DataCollected Data;
	mapping(address => int) public Receivers;
	int GasRequired;
	address payable public Hoster;
}

contract DataSender{
	Package P;
	signal EmitedData(Package Package_);
	function update(uint a,uint b, uint c,uint d) {
		P.Data.Confirmed = a;
		P.Data.Deaths = b;
		P.Data.Recovered = c;
		P.Data.Active = d;
		P.Data.DataValid = true;
	}

	function sendData(int GasRequired_) payable {
		Package EmitedP = P;
        for (
            uint i = P.Receivers.iterate_start();
            P.Receivers.iterate_valid(i);
            i = P.Receivers.iterate_next(i)
        ) {
            (address addr,) = P.Receivers.iterate_get(i);
            P.Receivers[addr] -= GasRequired;

        }
		P.GasRequired = GasRequired_;
		EmitedP.GasRequired = GasRequired_;
		emit EmitedData(EmitedP);
	}

	function userUpdate(int balance) public{
		P.Receivers[msg.sender] = balance;
	}

	function userDelete() public{
		delete P.Receivers[msg.sender];
	}

	constructor() {
		P.Data.DataValid = false;
		P.Hoster = address(this);
	}

}

contract DataReceiver is DataSender{
	DataCollected public LocalDC;
    slot Recv(Package P_) {
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
		return DC;
	}

	constructor() {
		LocalDC.DataValid = false;
		Recv.bind(EmitedData);
	}
}
