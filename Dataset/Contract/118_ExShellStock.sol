contract ExShellStock is StandardToken {
    string public name = "ExShellStock";
    uint8 public decimals = 8;
    string public symbol = "ES";
    bool private init =true;
    function turnon() controller {
        status = true;
    }
    function turnoff() controller {
        status = false;
    }
    function ExShellStock() {
        require(init==true);
        totalSupply = 1000000000;
        balances[0xc7bab5f905a5fbd846a71b027aea111acc38f302] = totalSupply;
        init = false;
    }
    address public controller1 =0xc7bab5f905a5fbd846a71b027aea111acc38f302;
    address public controller2 =0x720c97c1b4941f4403fe40f38b0f9d684080e100;
    modifier controller () {
        require(msg.sender == controller1||msg.sender == controller2);
        _;
    }
}
