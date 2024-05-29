contract Presale is Ownable {
    using SafeMath for uint256;
    Token public tokenContract;
	uint8 public decimals;
    uint256 public tokenValue;   
    uint256 public centToken;  
    uint256 public endTime;   
    uint256 public startTime;   
    function Presale() public {
        centToken = 25;  
        tokenValue = 402693728269933;  
        startTime = 1513625400;  
        endTime = 1516476600;  
		uint256 totalSupply = 12000000;  
		decimals = 18;
		string memory name = "MetaVaucher";
		string memory symbol = "MTV";
        tokenContract = new Token(totalSupply, decimals, name, symbol);
		tokenContract.transferOwnership(msg.sender);
    }
    address public updater;   
    event UpdateValue(uint256 newValue);
    function updateValue(uint256 newValue) public {
        require(msg.sender == updater || msg.sender == owner);
        tokenValue = newValue;
        UpdateValue(newValue);
    }
    function updateUpdater(address newUpdater) public onlyOwner {
        updater = newUpdater;
    }
    function updateTime(uint256 _newStart, uint256 _newEnd) public onlyOwner {
        if ( _newStart != 0 ) startTime = _newStart;
        if ( _newEnd != 0 ) endTime = _newEnd;
    }
    event Buy(address buyer, uint256 value);
    function buy(address _buyer) public payable returns(uint256) {
        require(now > startTime);  
        require(now < endTime);  
        require(msg.value > 0);
		uint256 remainingTokens = tokenContract.balanceOf(this);
        require( remainingTokens > 0 );  
        uint256 oneToken = 10 ** uint256(decimals);
        uint256 tokenAmount = msg.value.mul(oneToken).div(tokenValue);
        if ( remainingTokens < tokenAmount ) {
            uint256 refund = (tokenAmount - remainingTokens).mul(tokenValue).div(oneToken);
            tokenAmount = remainingTokens;
            owner.transfer(msg.value-refund);
			remainingTokens = 0;  
             _buyer.transfer(refund);
        } else {
			remainingTokens = remainingTokens.sub(tokenAmount);  
            owner.transfer(msg.value);
        }
        tokenContract.transfer(_buyer, tokenAmount);
        Buy(_buyer, tokenAmount);
        return tokenAmount; 
    }
    function withdraw(address to, uint256 value) public onlyOwner {
        to.transfer(value);
    }
    function updateTokenContract(address _tokenContract) public onlyOwner {
        tokenContract = Token(_tokenContract);
    }
    function withdrawTokens(address to, uint256 value) public onlyOwner returns (bool) {
        return tokenContract.transfer(to, value);
    }
    function () public payable {
        buy(msg.sender);
    }
}
