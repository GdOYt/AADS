contract SaleBase is OperationalControl, ERC721Holder {
    using SafeMath for uint256;
    event SaleCreated(uint256 tokenID, uint256 startingPrice, uint256 endingPrice, uint256 duration, uint256 startedAt);
    event TeamSaleCreated(uint256[9] tokenIDs, uint256 startingPrice, uint256 endingPrice, uint256 duration, uint256 startedAt);
    event SaleWinner(uint256 tokenID, uint256 totalPrice, address winner);
    event TeamSaleWinner(uint256[9] tokenIDs, uint256 totalPrice, address winner);
    event SaleCancelled(uint256 tokenID, address sellerAddress);
    event EtherWithdrawed(uint256 value);
    struct Sale {
        address seller;
        uint256 startingPrice;
        uint256 endingPrice;
        uint256 duration;
        uint256 startedAt;
        uint256[9] tokenIds;
    }
    MLBNFT public nonFungibleContract;
    uint256 public ownerCut = 500;  
    mapping (uint256 => Sale) tokenIdToSale;
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }
    function _escrow(address _owner, uint256 _tokenId) internal {
        nonFungibleContract.safeTransferFrom(_owner, this, _tokenId);
    }
    function _transfer(address _owner, address _receiver, uint256 _tokenId) internal {
        nonFungibleContract.transferFrom(_owner, _receiver, _tokenId);
    }
    function _addSale(uint256 _tokenId, Sale _sale) internal {
        require(_sale.duration >= 1 minutes);
        tokenIdToSale[_tokenId] = _sale;
        emit SaleCreated(
            uint256(_tokenId),
            uint256(_sale.startingPrice),
            uint256(_sale.endingPrice),
            uint256(_sale.duration),
            uint256(_sale.startedAt)
        );
    }
    function _addTeamSale(uint256[9] _tokenIds, Sale _sale) internal {
        require(_sale.duration >= 1 minutes);
        for(uint ii = 0; ii < 9; ii++) {
            require(_tokenIds[ii] != 0);
            require(nonFungibleContract.exists(_tokenIds[ii]));
            tokenIdToSale[_tokenIds[ii]] = _sale;
        }
        emit TeamSaleCreated(
            _tokenIds,
            uint256(_sale.startingPrice),
            uint256(_sale.endingPrice),
            uint256(_sale.duration),
            uint256(_sale.startedAt)
        );
    }
    function _cancelSale(uint256 _tokenId, address _seller) internal {
        Sale memory saleItem = tokenIdToSale[_tokenId];
        if(saleItem.tokenIds[1] != 0) {
            for(uint ii = 0; ii < 9; ii++) {
                _removeSale(saleItem.tokenIds[ii]);
                _transfer(address(this), _seller, saleItem.tokenIds[ii]);
            }
            emit SaleCancelled(_tokenId, _seller);
        } else {
            _removeSale(_tokenId);
            _transfer(address(this), _seller, _tokenId);
            emit SaleCancelled(_tokenId, _seller);
        }
    }
    function _bid(uint256 _tokenId, uint256 _bidAmount)
        internal
        returns (uint256)
    {
        Sale storage _sale = tokenIdToSale[_tokenId];
        uint256[9] memory tokenIdsStore = tokenIdToSale[_tokenId].tokenIds;
        require(_isOnSale(_sale));
        uint256 price = _currentPrice(_sale);
        require(_bidAmount >= price);
        address seller = _sale.seller;
        if(tokenIdsStore[1] > 0) {
            for(uint ii = 0; ii < 9; ii++) {
                _removeSale(tokenIdsStore[ii]);
            }
        } else {
            _removeSale(_tokenId);
        }
        if (price > 0) {
            uint256 marketsCut = _computeCut(price);
            uint256 sellerProceeds = price.sub(marketsCut);
            seller.transfer(sellerProceeds);
        }
        uint256 bidExcess = _bidAmount.sub(price);
        msg.sender.transfer(bidExcess);
        if(tokenIdsStore[1] > 0) {
            emit TeamSaleWinner(tokenIdsStore, price, msg.sender);
        } else {
            emit SaleWinner(_tokenId, price, msg.sender);
        }
        return price;
    }
    function _removeSale(uint256 _tokenId) internal {
        delete tokenIdToSale[_tokenId];
    }
    function _isOnSale(Sale memory _sale) internal pure returns (bool) {
        return (_sale.startedAt > 0);
    }
    function _currentPrice(Sale memory _sale)
        internal
        view
        returns (uint256)
    {
        uint256 secondsPassed = 0;
        if (now > _sale.startedAt) {
            secondsPassed = now - _sale.startedAt;
        }
        return _computeCurrentPrice(
            _sale.startingPrice,
            _sale.endingPrice,
            _sale.duration,
            secondsPassed
        );
    }
    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
        internal
        pure
        returns (uint256)
    {
        if (_secondsPassed >= _duration) {
            return _endingPrice;
        } else {
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;
            return uint256(currentPrice);
        }
    }
    function _computeCut(uint256 _price) internal view returns (uint256) {
        return _price.mul(ownerCut.div(10000));
    }
}
