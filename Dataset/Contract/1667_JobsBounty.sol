contract JobsBounty is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    string public companyName;  
    string public jobPost;  
    uint public endDate;  
    address public INDToken;
    constructor(string _companyName,
                string _jobPost,
                uint _endDate,
                address _INDToken
                ) public{
        companyName = _companyName;
        jobPost = _jobPost ;
        endDate = _endDate;
        INDToken = _INDToken;
    }
    function ownBalance() public view returns(uint256) {
        return SafeMath.div(ERC20(INDToken).balanceOf(this),1 ether);
    }
    function payOutBounty(address _referrerAddress, address _candidateAddress) external onlyOwner nonReentrant returns(bool){
        assert(block.timestamp >= endDate);
        assert(_referrerAddress != address(0x0));
        assert(_candidateAddress != address(0x0));
        uint256 individualAmounts = SafeMath.mul(SafeMath.div((ERC20(INDToken).balanceOf(this)),100),50);
        assert(ERC20(INDToken).transfer(_candidateAddress, individualAmounts));
        assert(ERC20(INDToken).transfer(_referrerAddress, individualAmounts));
        return true;    
    }
    function withdrawERC20Token(address anyToken) external onlyOwner nonReentrant returns(bool){
        assert(block.timestamp >= endDate);
        assert(ERC20(anyToken).transfer(owner, ERC20(anyToken).balanceOf(this)));        
        return true;
    }
    function withdrawEther() external onlyOwner nonReentrant returns(bool){
        if(address(this).balance > 0){
            owner.transfer(address(this).balance);
        }        
        return true;
    }
}
