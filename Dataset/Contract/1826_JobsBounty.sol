contract JobsBounty is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    string public companyName;  
    string public jobPost;  
    uint public endDate;  
    address public INDToken = 0xf8e386eda857484f5a12e4b5daa9984e06e73705;
    constructor(string _companyName,
                string _jobPost,
                uint _endDate
                ) public{
        companyName = _companyName;
        jobPost = _jobPost ;
        endDate = _endDate;
    }
    function ownBalance() public view returns(uint256) {
        return ERC20(INDToken).balanceOf(this);
    }
    function payOutBounty(address _referrerAddress, address _candidateAddress) public onlyOwner nonReentrant returns(bool){
        uint256 individualAmounts = (ERC20(INDToken).balanceOf(this) / 100) * 50;
        assert(block.timestamp >= endDate);
        assert(ERC20(INDToken).transfer(_candidateAddress, individualAmounts));
        assert(ERC20(INDToken).transfer(_referrerAddress, individualAmounts));
        return true;    
    }
    function withdrawERC20Token(address anyToken) public onlyOwner nonReentrant returns(bool){
        assert(block.timestamp >= endDate);
        assert(ERC20(anyToken).transfer(owner, ERC20(anyToken).balanceOf(this)));        
        return true;
    }
    function withdrawEther() public nonReentrant returns(bool){
        if(address(this).balance > 0){
            owner.transfer(address(this).balance);
        }        
        return true;
    }
}
