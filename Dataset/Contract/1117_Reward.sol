contract Reward {
        using SafeMath for uint256;
    address public admin;
    address public thisContractAddress;
    address public tokenContractAddress = 0x42be9831FFF77972c1D0E1eC0aA9bdb3CaA04D47;
    address public tokenSaleAddress = 0x1C49d3c4895E7b136e8F8b804F1279068d4c3c96;
    uint public contractCreationBlockNumber;
    uint public contractCreationBlockTime;
    uint public tokenSaleClosingTime;
    bool public claimTokenWindowOpen;
    uint public windowOpenTime;
    EthertoteToken token;       
    TokenSale tokensale;
	event Log(string text);
    modifier onlyAdmin { 
        require(
            msg.sender == admin
        ); 
        _; 
    }
    modifier onlyContract { 
        require(
            msg.sender == admin ||
            msg.sender == thisContractAddress
        ); 
        _; 
    }   
    constructor() public payable {
        admin = msg.sender;
        thisContractAddress = address(this);
        contractCreationBlockNumber = block.number;
        token = EthertoteToken(tokenContractAddress);
        tokensale = TokenSale(tokenSaleAddress);
	    emit Log("Reward contract created.");
    }
    function () private payable {}
    Claimant[] public claimants;   
        struct Claimant {
        address claimantAddress;
        uint claimantAmount;
        bool claimantHasClaimed;
    }
    function addClaimant(address _address, uint _amount, bool) onlyAdmin public {
            Claimant memory newClaimant = Claimant ({
                claimantAddress: _address,
                claimantAmount: _amount,
                claimantHasClaimed: false
                });
                claimants.push(newClaimant);
    }
    function adjustEntitlement(address _address, uint _amount) onlyAdmin public {
        for (uint i = 0; i < claimants.length; i++) {
            if(_address == claimants[i].claimantAddress) {
                claimants[i].claimantAmount = _amount;
            }
            else revert();
            }  
    }
    function recoverTokens() onlyAdmin public {
        require(now < (showTokenSaleClosingTime().add(61 days)));
        token.transfer(admin, token.balanceOf(thisContractAddress));
    }
    function ClaimEth() onlyAdmin public {
        address(admin).transfer(address(this).balance);
    }  
    function claimTokens() public {
        require(now > showTokenSaleClosingTime());
        require(now < (showTokenSaleClosingTime().add(60 days)));
          for (uint i = 0; i < claimants.length; i++) {
            if(msg.sender == claimants[i].claimantAddress) {
                require(claimants[i].claimantHasClaimed == false);
                token.transfer(msg.sender, claimants[i].claimantAmount);
                claimants[i].claimantHasClaimed = true;
            }
          }
    }
    function checkClaimEntitlement() public view returns(uint) {
        for (uint i = 0; i < claimants.length; i++) {
            if(msg.sender == claimants[i].claimantAddress) {
                require(claimants[i].claimantHasClaimed == false);
                return claimants[i].claimantAmount;
            }
            else return 0;
        }  
    }
    function checkClaimEntitlementofWallet(address _address) public view returns(uint) {
        for (uint i = 0; i < claimants.length; i++) {
            if(_address == claimants[i].claimantAddress) {
                require(claimants[i].claimantHasClaimed == false);
                return claimants[i].claimantAmount;
            }
            else return 0;
        }  
    }
    function thisContractBalance() public view returns(uint) {
      return address(this).balance;
    }
    function thisContractTokenBalance() public view returns(uint) {
      return token.balanceOf(thisContractAddress);
    }
    function showTokenSaleClosingTime() public view returns(uint) {
        return tokensale.closingTime();
    }
}
