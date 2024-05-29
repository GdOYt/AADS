contract ExShellToken is StandardToken {
    string public name = "ExShellToken";
    uint8 public decimals = 8;
    string public symbol = "ET";
    bool private init =true;
    function turnon() controller {
        status = true;
    }
    function turnoff() controller {
        status = false;
    }
    function ExShellToken() {
        require(init==true);
        totalSupply = 2000000000;
        balances[0xa089a405b1df71a6155705fb2bce87df2a86a9e4] = totalSupply;
        init = false;
    }
    address public controller1 =0xa089a405b1df71a6155705fb2bce87df2a86a9e4;
    address public controller2 =0x5aa64423529e43a53c7ea037a07f94abc0c3a111;
    modifier controller () {
        require(msg.sender == controller1||msg.sender == controller2);
        _;
    }
}
