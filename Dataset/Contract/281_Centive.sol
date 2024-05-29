contract Centive is Burnable, Ownable {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    address public releaseAgent;
    bool public released = false;
    mapping(address => bool) public transferAgents;
    modifier canTransfer(address _sender) {
        require(transferAgents[_sender] || released);
        _;
    }
    modifier inReleaseState(bool releaseState) {
        require(releaseState == released);
        _;
    }
    modifier onlyReleaseAgent() {
        require(msg.sender == releaseAgent);
        _;
    }
    constructor(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }
    function setReleaseAgent(address addr) external onlyOwner inReleaseState(false) {
        releaseAgent = addr;
    }
    function release() external onlyReleaseAgent inReleaseState(false) {
        released = true;
    }
    function setTransferAgent(address addr, bool state) external onlyOwner inReleaseState(false) {
        transferAgents[addr] = state;
    }
    function transfer(address _to, uint _value) public canTransfer(msg.sender) returns (bool success) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint _value) public canTransfer(_from) returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }
    function burn(uint256 _value) public onlyOwner returns (bool success) {
        return super.burn(_value);
    }
    function burnFrom(address _from, uint256 _value) public onlyOwner returns (bool success) {
        return super.burnFrom(_from, _value);
    }
}
