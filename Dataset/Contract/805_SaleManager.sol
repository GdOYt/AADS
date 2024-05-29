contract SaleManager is SaleBase {
    mapping (uint256 => uint256[3]) public lastTeamSalePrices;
    mapping (uint256 => uint256) public lastSingleSalePrices;
    mapping (uint256 => uint256) public seedTeamSaleCount;
    uint256 public seedSingleSaleCount = 0;
    uint256 public constant SINGLE_SALE_MULTIPLIER = 35;
    uint256 public constant TEAM_SALE_MULTIPLIER = 12;
    uint256 public constant STARTING_PRICE = 10 finney;
    uint256 public constant SALES_DURATION = 1 days;
    bool public isBatchSupported = true;
    constructor() public {
        require(ownerCut <= 10000);  
        require(msg.sender != address(0));
        paused = true;
        gameManagerPrimary = msg.sender;
        gameManagerSecondary = msg.sender;
        bankManager = msg.sender;
    }
    function unpause() public onlyGameManager whenPaused {
        require(nonFungibleContract != address(0));
        super.unpause();
    }
    function _withdrawBalance() internal {
        bankManager.transfer(address(this).balance);
    }
    function() external payable {
        address nftAddress = address(nonFungibleContract);
        require(
            msg.sender == address(this) || 
            msg.sender == gameManagerPrimary ||
            msg.sender == gameManagerSecondary ||
            msg.sender == bankManager ||
            msg.sender == nftAddress
        );
    }
    function _createSale(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        internal
    {
        Sale memory sale = Sale(
            _seller,
            _startingPrice,
            _endingPrice,
            _duration,
            now,
            [_tokenId,0,0,0,0,0,0,0,0]
        );
        _addSale(_tokenId, sale);
    }
    function _createTeamSale(
        uint256[9] _tokenIds,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller)
        internal {
        Sale memory sale = Sale(
            _seller,
            _startingPrice,
            _endingPrice,
            _duration,
            now,
            _tokenIds
        );
        _addTeamSale(_tokenIds, sale);
    }
    function cancelSale(uint256 _tokenId) external whenNotPaused {
        Sale memory sale = tokenIdToSale[_tokenId];
        require(_isOnSale(sale));
        address seller = sale.seller;
        require(msg.sender == seller);
        _cancelSale(_tokenId, seller);
    }
    function cancelSaleWhenPaused(uint256 _tokenId) external whenPaused onlyGameManager {
        Sale memory sale = tokenIdToSale[_tokenId];
        require(_isOnSale(sale));
        address seller = sale.seller;
        _cancelSale(_tokenId, seller);
    }
    function getSale(uint256 _tokenId) external view returns (address seller, uint256 startingPrice, uint256 endingPrice, uint256 duration, uint256 startedAt, uint256[9] tokenIds) {
        Sale memory sale = tokenIdToSale[_tokenId];
        require(_isOnSale(sale));
        return (
            sale.seller,
            sale.startingPrice,
            sale.endingPrice,
            sale.duration,
            sale.startedAt,
            sale.tokenIds
        );
    }
    function getCurrentPrice(uint256 _tokenId) external view returns (uint256) {
        Sale memory sale = tokenIdToSale[_tokenId];
        require(_isOnSale(sale));
        return _currentPrice(sale);
    }
    function _averageSalePrice(uint256 _saleType, uint256 _teamId) internal view returns (uint256) {
        uint256 _price = 0;
        if(_saleType == 0) {
            for(uint256 ii = 0; ii < 10; ii++) {
                _price = _price.add(lastSingleSalePrices[ii]);
            }
            _price = (_price.div(10)).mul(SINGLE_SALE_MULTIPLIER.div(10));
        } else {
            for (uint256 i = 0; i < 3; i++) {
                _price = _price.add(lastTeamSalePrices[_teamId][i]);
            }
            _price = (_price.div(3)).mul(TEAM_SALE_MULTIPLIER.div(10));
            _price = _price.mul(9);
        }
        return _price;
    }
    function createSale(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration, address _owner) external whenNotPaused {
        require(msg.sender == address(nonFungibleContract));
        require(nonFungibleContract.checkIsAttached(_tokenId) == 0);
        _escrow(_owner, _tokenId);
        _createSale(
            _tokenId,
            _startingPrice,
            _endingPrice,
            _duration,
            _owner
        );
    }
    function userCreateSaleIfApproved (uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration) external whenNotPaused {
        require(nonFungibleContract.getApproved(_tokenId) == address(this) || nonFungibleContract.isApprovedForAll(msg.sender, address(this)));
        require(nonFungibleContract.checkIsAttached(_tokenId) == 0);
        _escrow(msg.sender, _tokenId);
        _createSale(
            _tokenId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }
    function withdrawSaleManagerBalances() public onlyBanker {
        _withdrawBalance();
    }
    function setOwnerCut(uint256 _newCut) external onlyBanker {
        require(_newCut <= 10000);
        ownerCut = _newCut;
    }
    function createSingleSeedAuction(
        uint8 _teamId,
        uint8 _posId,
        uint256 _attributes,
        uint256 _playerOverrideId,
        uint256 _mlbPlayerId,
        uint256 _startPrice,
        uint256 _endPrice,
        uint256 _saleDuration)
        public
        onlyGameManager
        whenNotPaused {
        require(nonFungibleContract != address(0));
        require(_teamId != 0);
        uint256 nftId = nonFungibleContract.createSeedCollectible(_teamId,_posId,_attributes,address(this),0, _playerOverrideId, _mlbPlayerId);
        uint256 startPrice = 0;
        uint256 endPrice = 0;
        uint256 duration = 0;
        if(_startPrice == 0) {
            startPrice = _computeNextSeedPrice(0, _teamId);
        } else {
            startPrice = _startPrice;
        }
        if(_endPrice != 0) {
            endPrice = _endPrice;
        } else {
            endPrice = 0;
        }
        if(_saleDuration == 0) {
            duration = SALES_DURATION;
        } else {
            duration = _saleDuration;
        }
        _createSale(
            nftId,
            startPrice,
            endPrice,
            duration,
            address(this)
        );
    }
    function createPromoSeedAuction(
        uint8 _teamId,
        uint8 _posId,
        uint256 _attributes,
        uint256 _playerOverrideId,
        uint256 _mlbPlayerId,
        uint256 _startPrice,
        uint256 _endPrice,
        uint256 _saleDuration)
        public
        onlyGameManager
        whenNotPaused {
        require(nonFungibleContract != address(0));
        require(_teamId != 0);
        uint256 nftId = nonFungibleContract.createPromoCollectible(_teamId, _posId, _attributes, address(this), 0, _playerOverrideId, _mlbPlayerId);
        uint256 startPrice = 0;
        uint256 endPrice = 0;
        uint256 duration = 0;
        if(_startPrice == 0) {
            startPrice = _computeNextSeedPrice(0, _teamId);
        } else {
            startPrice = _startPrice;
        }
        if(_endPrice != 0) {
            endPrice = _endPrice;
        } else {
            endPrice = 0;
        }
        if(_saleDuration == 0) {
            duration = SALES_DURATION;
        } else {
            duration = _saleDuration;
        }
        _createSale(
            nftId,
            startPrice,
            endPrice,
            duration,
            address(this)
        );
    }
    function createTeamSaleAuction(
        uint8 _teamId,
        uint256[9] _tokenIds,
        uint256 _startPrice,
        uint256 _endPrice,
        uint256 _saleDuration)
        public
        onlyGameManager
        whenNotPaused {
        require(_teamId != 0);
        for(uint ii = 0; ii < _tokenIds.length; ii++){
            require(nonFungibleContract.getTeamId(_tokenIds[ii]) == _teamId);
        }
        uint256 startPrice = 0;
        uint256 endPrice = 0;
        uint256 duration = 0;
        if(_startPrice == 0) {
            startPrice = _computeNextSeedPrice(1, _teamId).mul(9);
        } else {
            startPrice = _startPrice;
        }
        if(_endPrice != 0) {
            endPrice = _endPrice;
        } else {
            endPrice = 0;
        }
        if(_saleDuration == 0) {
            duration = SALES_DURATION;
        } else {
            duration = _saleDuration;
        }
        _createTeamSale(
            _tokenIds,
            startPrice,
            endPrice,
            duration,
            address(this)
        );
    }
    function _computeNextSeedPrice(uint256 _saleType, uint256 _teamId) internal view returns (uint256) {
        uint256 nextPrice = _averageSalePrice(_saleType, _teamId);
        require(nextPrice == nextPrice);
        if (nextPrice < STARTING_PRICE) {
            nextPrice = STARTING_PRICE;
        }
        return nextPrice;
    }
    bool public isSalesManager = true;
    function bid(uint256 _tokenId) public whenNotPaused payable {
        Sale memory sale = tokenIdToSale[_tokenId];
        address seller = sale.seller;
        uint256 price = _bid(_tokenId, msg.value);
        if(sale.tokenIds[1] > 0) {
            for (uint256 i = 0; i < 9; i++) {
                _transfer(address(this), msg.sender, sale.tokenIds[i]);
            }
            price = price.div(9);
        } else {
            _transfer(address(this), msg.sender, _tokenId);
        }
        if (seller == address(this)) {
            if(sale.tokenIds[1] > 0){
                uint256 _teamId = nonFungibleContract.getTeamId(_tokenId);
                lastTeamSalePrices[_teamId][seedTeamSaleCount[_teamId] % 3] = price;
                seedTeamSaleCount[_teamId]++;
            } else {
                lastSingleSalePrices[seedSingleSaleCount % 10] = price;
                seedSingleSaleCount++;
            }
        }
    }
    function setNFTContractAddress(address _nftAddress) public onlyGameManager {
        require (_nftAddress != address(0));        
        nonFungibleContract = MLBNFT(_nftAddress);
    }
    function assetTransfer(address _to, uint256 _tokenId) public onlyGameManager {
        require(_tokenId != 0);
        nonFungibleContract.transferFrom(address(this), _to, _tokenId);
    }
    function batchAssetTransfer(address _to, uint256[] _tokenIds) public onlyGameManager {
        require(isBatchSupported);
        require (_tokenIds.length > 0);
        for(uint i = 0; i < _tokenIds.length; i++){
            require(_tokenIds[i] != 0);
            nonFungibleContract.transferFrom(address(this), _to, _tokenIds[i]);
        }
    }
    function createSeedTeam(uint8 _teamId, uint256[9] _attributes, uint256[9] _mlbPlayerId) public onlyGameManager whenNotPaused {
        require(_teamId != 0);
        for(uint ii = 0; ii < 9; ii++) {
            nonFungibleContract.createSeedCollectible(_teamId, uint8(ii.add(1)), _attributes[ii], address(this), 0, 0, _mlbPlayerId[ii]);
        }
    }
    function batchCancelSale(uint256[] _tokenIds) external whenNotPaused {
        require(isBatchSupported);
        require(_tokenIds.length > 0);
        for(uint ii = 0; ii < _tokenIds.length; ii++){
            Sale memory sale = tokenIdToSale[_tokenIds[ii]];
            require(_isOnSale(sale));
            address seller = sale.seller;
            require(msg.sender == seller);
            _cancelSale(_tokenIds[ii], seller);
        }
    }
    function updateBatchSupport(bool _flag) public onlyGameManager {
        isBatchSupported = _flag;
    }
    function batchCreateSingleSeedAuction(
        uint8[] _teamIds,
        uint8[] _posIds,
        uint256[] _attributes,
        uint256[] _playerOverrideIds,
        uint256[] _mlbPlayerIds,
        uint256 _startPrice)
        public
        onlyGameManager
        whenNotPaused {
        require (isBatchSupported);
        require (_teamIds.length > 0 &&
            _posIds.length > 0 &&
            _attributes.length > 0 &&
            _playerOverrideIds.length > 0 &&
            _mlbPlayerIds.length > 0 );
        require(nonFungibleContract != address(0));
        uint256 nftId;
        require (_startPrice != 0);
        for(uint ii = 0; ii < _mlbPlayerIds.length; ii++){
            require(_teamIds[ii] != 0);
            nftId = nonFungibleContract.createSeedCollectible(
                        _teamIds[ii],
                        _posIds[ii],
                        _attributes[ii],
                        address(this),
                        0,
                        _playerOverrideIds[ii],
                        _mlbPlayerIds[ii]);
            _createSale(
                nftId,
                _startPrice,
                0,
                SALES_DURATION,
                address(this)
            );
        }
    }
}
