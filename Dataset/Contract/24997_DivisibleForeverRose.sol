contract DivisibleForeverRose is ERC721 {
    address private contractOwner;
    mapping(uint => GiftToken) giftStorage;
	uint public totalSupply = 10; 
    bool public tradable = false;
    uint foreverRoseId = 1;
	mapping(address => mapping(uint => uint)) ownerToTokenShare;
	mapping(uint => mapping(address => uint)) tokenToOwnersHoldings;
	mapping(uint => bool) foreverRoseCreated;
    string public name;  
    string public symbol;           
    uint8 public decimals = 1;                                 
    string public version = "1.0";    
    struct GiftToken {
        uint256 giftId;
    } 
    function DivisibleForeverRose() public {
        contractOwner = msg.sender;
        name = "ForeverRose";
        symbol = "ROSE";  
        GiftToken memory newGift = GiftToken({
            giftId: foreverRoseId
        });
        giftStorage[foreverRoseId] = newGift;
        foreverRoseCreated[foreverRoseId] = true;
        _addNewOwnerHoldingsToToken(contractOwner, foreverRoseId, totalSupply);
        _addShareToNewOwner(contractOwner, foreverRoseId, totalSupply);
    }
    function() public {
        revert();
    }
    function totalSupply() public view returns (uint256 total) {
        return totalSupply;
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return ownerToTokenShare[_owner][foreverRoseId];
    }
    function transfer(address _to, uint256 _tokenId) external {
        require(tradable == true);
        require(_to != address(0));
        require(msg.sender != _to);
        uint256 _divisibility = _tokenId;
        require(tokenToOwnersHoldings[foreverRoseId][msg.sender] >= _divisibility);
        _removeShareFromLastOwner(msg.sender, foreverRoseId, _divisibility);
        _removeLastOwnerHoldingsFromToken(msg.sender, foreverRoseId, _divisibility);
        _addNewOwnerHoldingsToToken(_to, foreverRoseId, _divisibility);
        _addShareToNewOwner(_to, foreverRoseId, _divisibility);
        Transfer(msg.sender, _to, foreverRoseId);
    }
    function assignSharedOwnership(address _to, uint256 _divisibility)
                               onlyOwner external returns (bool success) 
                               {
        require(_to != address(0));
        require(msg.sender != _to);
        require(_to != address(this));
        require(tokenToOwnersHoldings[foreverRoseId][msg.sender] >= _divisibility);
        _removeLastOwnerHoldingsFromToken(msg.sender, foreverRoseId, _divisibility);
        _removeShareFromLastOwner(msg.sender, foreverRoseId, _divisibility);
        _addShareToNewOwner(_to, foreverRoseId, _divisibility); 
        _addNewOwnerHoldingsToToken(_to, foreverRoseId, _divisibility);
        Transfer(msg.sender, _to, foreverRoseId);
        return true;
    }
    function getForeverRose() public view returns(uint256 _foreverRoseId) {
        return giftStorage[foreverRoseId].giftId;
    }
    function turnOnTradable() public onlyOwner {
        tradable = true;
    }
	function _addShareToNewOwner(address _owner, uint _tokenId, uint _units) internal {
		ownerToTokenShare[_owner][_tokenId] += _units;
	}
	function _addNewOwnerHoldingsToToken(address _owner, uint _tokenId, uint _units) internal {
		tokenToOwnersHoldings[_tokenId][_owner] += _units;
	}
	function _removeShareFromLastOwner(address _owner, uint _tokenId, uint _units) internal {
		ownerToTokenShare[_owner][_tokenId] -= _units;
	}
	function _removeLastOwnerHoldingsFromToken(address _owner, uint _tokenId, uint _units) internal {
		tokenToOwnersHoldings[_tokenId][_owner] -= _units;
	}
    function withdrawEther() onlyOwner public returns(bool) {
        return contractOwner.send(this.balance);
    }
     modifier onlyExistentToken(uint _tokenId) {
	    require(foreverRoseCreated[_tokenId] == true);
	    _;
	}
    modifier onlyOwner(){
         require(msg.sender == contractOwner);
         _;
     }
}
