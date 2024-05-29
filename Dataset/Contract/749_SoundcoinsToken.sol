contract SoundcoinsToken is Token {
    address _teamAddress;  
    address _saleAddress;
    uint256 availableSupply = 250000000;
    uint256 minableSupply = 750000000;
    address public SoundcoinsAddress;
    uint256 public total_SDCC_supply = 0;
    mapping (address => uint256) balances_chips;
    mapping (address => uint256) holdings_SDC;
    uint256 holdingsSupply = 0;
    modifier onlyAuthorized {
        require(msg.sender == SoundcoinsAddress);
        _;
    }
    function SoundcoinsToken(address _crowdsaleContract) public {
        standard = "Soundcoins Token  V1.0";
        name = "Soundcoins";
        symbol = "SDC";
        decimals = 0;
        supply = 1000000000;
        _teamAddress = msg.sender;
        balances[msg.sender] = 100000000;
        _saleAddress = _crowdsaleContract;
        balances[_crowdsaleContract] = 150000000;
    }
    function getAvailableSupply() public returns (uint256){
        return availableSupply;
    }
    function getMinableSupply() public returns (uint256){
        return minableSupply;
    }
    function getHoldingsSupply() public returns (uint256){
        return holdingsSupply;
    }
    function getSDCCSupply() public returns (uint256){
        return total_SDCC_supply;
    }
    function getSoundcoinsAddress() public returns (address){
        return SoundcoinsAddress;
    }
    function hasSDC(address _address,uint256 _quantity) public returns (bool success){
        return (balances[_address] >= _quantity);
    }
    function hasSDCC(address _address, uint256 _quantity) public returns (bool success){
        return (chipBalanceOf(_address) >= _quantity);
    }
    function createSDC(address _address, uint256 _init_quantity, uint256 _quantity) onlyAuthorized public returns (bool success){
        require(minableSupply >= 0);
        balances[_address] = balances[_address].add(_quantity);
        availableSupply = availableSupply.add(_quantity);
        holdings_SDC[_address] = holdings_SDC[_address].sub(_init_quantity);
        minableSupply = minableSupply.sub(_quantity.sub(_init_quantity));
        holdingsSupply = holdingsSupply.sub(_init_quantity);
        return true;
    }
    function eliminateSDCC(address _address, uint256 _quantity) onlyAuthorized public returns (bool success){
        balances_chips[_address] = balances_chips[_address].sub(_quantity);
        total_SDCC_supply = total_SDCC_supply.sub(_quantity);
        return true;
    }
    function createSDCC(address _address, uint256 _quantity) onlyAuthorized public returns (bool success){
        balances_chips[_address] = balances_chips[_address].add(_quantity);
        total_SDCC_supply = total_SDCC_supply.add(_quantity);
        return true;
    }
    function chipBalanceOf(address _address) public returns (uint256 _amount) {
        return balances_chips[_address];
    }
    function transferChips(address _from, address _to, uint256 _value) onlyAuthorized public returns (bool success) {
        require(_to != 0x0 && _to != address(msg.sender));
        balances_chips[_from] = balances_chips[_from].sub(_value);  
        balances_chips[_to] = balances_chips[_to].add(_value);                
        return true;
    }
    function changeSoundcoinsContract(address _newAddress) public onlyOwner {
        SoundcoinsAddress = _newAddress;
    }
    function stakeSDC(address _address, uint256 amount) onlyAuthorized public returns(bool){
        balances[_address] = balances[_address].sub(amount);
        availableSupply = availableSupply.sub(amount);
        holdings_SDC[_address] = holdings_SDC[_address].add(amount);
        holdingsSupply = holdingsSupply.add(amount);
        return true;
    }
    function endStake(address _address, uint256 amount) onlyAuthorized public returns(bool){
        balances[_address] = balances[_address].add(amount);
        availableSupply = availableSupply.add(amount);
        holdings_SDC[_address] = holdings_SDC[_address].sub(amount);
        holdingsSupply = holdingsSupply.sub(amount);
        return true;
    }
}
