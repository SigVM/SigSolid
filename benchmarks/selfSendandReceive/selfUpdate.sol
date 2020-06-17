contract counter{
    uint count;
	signal sigl(uint val);
    slot slt(uint val){
        count = count + 1;
        require(count <= 10,"count already reach ten");
        emit sigl(count);
    }
    function Start_Emit() public {
        count = count + 1;
        emit sigl(count);
    }

    constructor(){
        count = 0;
    }

}
