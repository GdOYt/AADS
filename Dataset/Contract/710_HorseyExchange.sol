contract HorseyExchange is Pausable {  
    using SafeMath for uint256;
    event HorseyDeposit(uint256 tokenId, uint256 price);
    event SaleCanceled(uint256 tokenId);
    event HorseyPurchased(uint256 tokenId, address newOwner, uint256 totalToPay);
    uint256 public marketMakerFee = 3;
    uint256 collectedFees = 0;
    ERC721Basic public token;
    struct SaleData {
        uint256 price;
        address owner;
    }
    mapping (uint256 => SaleData) market;
    mapping (address => uint256[]) userBarn;
    constructor() Pausable() public {
    }
    function setStables(address _token) external
    onlyOwner()
    {
        require(address(_token) != 0,"Address of token is zero");
        token = ERC721Basic(_token);
    }
    function setMarketFees(uint256 fees) external
    onlyOwner()
    {
        marketMakerFee = fees;
    }
    function getTokensOnSale(address user) external view returns(uint256[]) {
        return userBarn[user];
    }
    function getTokenPrice(uint256 tokenId) public view
    isOnMarket(tokenId) returns (uint256) {
        return market[tokenId].price + (market[tokenId].price.div(100).mul(marketMakerFee));
    }
    function depositToExchange(uint256 tokenId, uint256 price) external
    whenNotPaused()
    isTokenOwner(tokenId)
    nonZeroPrice(price)
    tokenAvailable() {
        require(token.getApproved(tokenId) == address(this),"Exchange is not allowed to transfer");
        token.transferFrom(msg.sender, address(this), tokenId);
        market[tokenId] = SaleData(price,msg.sender);
        userBarn[msg.sender].push(tokenId);
        emit HorseyDeposit(tokenId, price);
    }
    function cancelSale(uint256 tokenId) external 
    whenNotPaused()
    originalOwnerOf(tokenId) 
    tokenAvailable() returns (bool) {
        token.transferFrom(address(this),msg.sender,tokenId);
        delete market[tokenId];
        _removeTokenFromBarn(tokenId, msg.sender);
        emit SaleCanceled(tokenId);
        return userBarn[msg.sender].length > 0;
    }
    function purchaseToken(uint256 tokenId) external payable 
    whenNotPaused()
    isOnMarket(tokenId) 
    tokenAvailable()
    notOriginalOwnerOf(tokenId)
    {
        uint256 totalToPay = getTokenPrice(tokenId);
        require(msg.value >= totalToPay, "Not paying enough");
        SaleData memory sale = market[tokenId];
        collectedFees += totalToPay - sale.price;
        sale.owner.transfer(sale.price);
        _removeTokenFromBarn(tokenId,  sale.owner);
        delete market[tokenId];
        token.transferFrom(address(this), msg.sender, tokenId);
        if(msg.value > totalToPay)  
        {
            msg.sender.transfer(msg.value.sub(totalToPay));
        }
        emit HorseyPurchased(tokenId, msg.sender, totalToPay);
    }
    function withdraw() external
    onlyOwner()
    {
        assert(collectedFees <= address(this).balance);
        owner.transfer(collectedFees);
        collectedFees = 0;
    }
    function _removeTokenFromBarn(uint tokenId, address barnAddress)  internal {
        uint256[] storage barnArray = userBarn[barnAddress];
        require(barnArray.length > 0,"No tokens to remove");
        int index = _indexOf(tokenId, barnArray);
        require(index >= 0, "Token not found in barn");
        for (uint256 i = uint256(index); i<barnArray.length-1; i++){
            barnArray[i] = barnArray[i+1];
        }
        barnArray.length--;
    }
    function _indexOf(uint item, uint256[] memory array) internal pure returns (int256){
        for(uint256 i = 0; i < array.length; i++){
            if(array[i] == item){
                return int256(i);
            }
        }
        return -1;
    }
    modifier isOnMarket(uint256 tokenId) {
        require(token.ownerOf(tokenId) == address(this),"Token not on market");
        _;
    }
    modifier isTokenOwner(uint256 tokenId) {
        require(token.ownerOf(tokenId) == msg.sender,"Not tokens owner");
        _;
    }
    modifier originalOwnerOf(uint256 tokenId) {
        require(market[tokenId].owner == msg.sender,"Not the original owner of");
        _;
    }
    modifier notOriginalOwnerOf(uint256 tokenId) {
        require(market[tokenId].owner != msg.sender,"Is the original owner");
        _;
    }
    modifier nonZeroPrice(uint256 price){
        require(price > 0,"Price is zero");
        _;
    }
    modifier tokenAvailable(){
        require(address(token) != 0,"Token address not set");
        _;
    }
}
