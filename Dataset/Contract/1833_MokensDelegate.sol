contract MokensDelegate is AbstractMokens {
    event MintPriceConfigurationChange(
        uint256 mintPrice,
        uint256 mintStepPrice,
        uint256 mintPriceOffset,
        uint256 mintPriceBuffer
    );
    event MintPriceChange(
        uint256 mintPrice
    );
    event TransferToParent(address indexed _toContract, uint256 indexed _toTokenId, uint256 _tokenId);
    event TransferFromParent(address indexed _fromContract, uint256 indexed _fromTokenId, uint256 _tokenId);
    function withdraw(address _sendTo, uint256 _amount) external onlyOwner {
        address mokensContract = address(this);
        require(_amount <= mokensContract.balance, "Amount is greater than balance.");
        _sendTo.transfer(_amount);
    }
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "_newOwner cannot be 0 address.");
        owner = _newOwner;
    }
    event LinkHashChange(
        uint256 indexed tokenId,
        bytes32 linkHash
    );
    function updateLinkHash(uint256 _tokenId, bytes32 _linkHash) external {
        address rootOwner = address(rootOwnerOf(_tokenId));
        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] ||
        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId] == msg.sender, "msg.sender not rootOwner/operator/approved.");
        uint256 data = mokens[_tokenId].data & MOKEN_DATA_MASK | uint256(_linkHash) & MOKEN_LINK_HASH_MASK;
        mokens[_tokenId].data = data;
        emit LinkHashChange(_tokenId, bytes32(data));
    }
    function setDefaultURIStart(string _defaultURIStart) external onlyOwner {
        defaultURIStart = _defaultURIStart;
    }
    function setDefaultURIEnd(string _defaultURIEnd) external onlyOwner {
        defaultURIEnd = _defaultURIEnd;
    }
    function tokenURI(uint256 _tokenId) external view returns (string tokenURIString) {
        require(_tokenId < mokensLength, "_tokenId does not exist.");
        return makeIntString(defaultURIStart, _tokenId, defaultURIEnd);
    }
    function makeIntString(string startString, uint256 v, string endString) private pure returns (string) {
        uint256 maxlength = 10;
        bytes memory reversed = new bytes(maxlength);
        uint256 numDigits = 0;
        if (v == 0) {
            numDigits = 1;
            reversed[0] = byte(48);
        }
        else {
            while (v != 0) {
                uint256 remainder = v % 10;
                v = v / 10;
                reversed[numDigits++] = byte(48 + remainder);
            }
        }
        bytes memory startStringBytes = bytes(startString);
        bytes memory endStringBytes = bytes(endString);
        uint256 startStringLength = startStringBytes.length;
        uint256 endStringLength = endStringBytes.length;
        bytes memory newStringBytes = new bytes(startStringLength + numDigits + endStringLength);
        uint256 i;
        for (i = 0; i < startStringLength; i++) {
            newStringBytes[i] = startStringBytes[i];
        }
        for (i = 0; i < numDigits; i++) {
            newStringBytes[i + startStringLength] = reversed[numDigits - 1 - i];
        }
        for (i = 0; i < endStringLength; i++) {
            newStringBytes[i + startStringLength + numDigits] = endStringBytes[i];
        }
        return string(newStringBytes);
    }
    event NewEra(
        uint256 index,
        bytes32 name,
        uint256 startTokenId
    );
    function startNextEra_(bytes32 _eraName) private returns (uint256 index, uint256 startTokenId) {
        require(_eraName != 0, "eraName is empty string.");
        require(eraIndex[_eraName] == 0, "Era name already exists.");
        startTokenId = mokensLength;
        index = eraLength++;
        eras[index] = _eraName;
        eraIndex[_eraName] = index + 1;
        emit NewEra(index, _eraName, startTokenId);
        return (index, startTokenId);
    }
    function startNextEra(bytes32 _eraName, uint256 _mintStepPrice, uint256 _mintPriceOffset, uint256 _mintPriceBuffer) external onlyOwner
    returns (uint256 index, uint256 startTokenId, uint256 mintPrice) {
        require(_mintStepPrice < 10000 ether, "mintStepPrice must be less than 10,000 ether.");
        mintStepPrice = _mintStepPrice;
        mintPriceOffset = _mintPriceOffset;
        mintPriceBuffer = _mintPriceBuffer;
        uint256 totalStepPrice = mokensLength * _mintStepPrice;
        require(totalStepPrice >= _mintPriceOffset, "(mokensLength * mintStepPrice) must be greater than or equal to mintPriceOffset.");
        mintPrice = totalStepPrice - _mintPriceOffset;
        emit MintPriceConfigurationChange(mintPrice, _mintStepPrice, _mintPriceOffset, _mintPriceBuffer);
        emit MintPriceChange(mintPrice);
        (index, startTokenId) = startNextEra_(_eraName);
        return (index, startTokenId, mintPrice);
    }
    function startNextEra(bytes32 _eraName) external onlyOwner returns (uint256 index, uint256 startTokenId) {
        return startNextEra_(_eraName);
    }
    function setMintPrice(uint256 _mintStepPrice, uint256 _mintPriceOffset, uint256 _mintPriceBuffer) external onlyOwner returns (uint256 mintPrice) {
        require(_mintStepPrice < 10000 ether, "mintStepPrice must be less than 10,000 ether.");
        mintStepPrice = _mintStepPrice;
        mintPriceOffset = _mintPriceOffset;
        mintPriceBuffer = _mintPriceBuffer;
        uint256 totalStepPrice = mokensLength * _mintStepPrice;
        require(totalStepPrice >= _mintPriceOffset, "(mokensLength * mintStepPrice) must be greater than or equal to mintPriceOffset.");
        mintPrice = totalStepPrice - _mintPriceOffset;
        emit MintPriceConfigurationChange(mintPrice, _mintStepPrice, _mintPriceOffset, _mintPriceBuffer);
        emit MintPriceChange(mintPrice);
        return mintPrice;
    }
    function addMintContract(address _contract) external onlyOwner {
        require(isContract(_contract), "Address is not a contract.");
        require(mintContractIndex[_contract] == 0, "Contract already added.");
        mintContracts.push(_contract);
        mintContractIndex[_contract] = mintContracts.length;
    }
    function removeMintContract(address _contract) external onlyOwner {
        uint256 index = mintContractIndex[_contract];
        require(index != 0, "Mint contract was not added.");
        uint256 lastIndex = mintContracts.length - 1;
        address lastMintContract = mintContracts[lastIndex];
        mintContracts[index - 1] = lastMintContract;
        mintContractIndex[lastMintContract] = index;
        delete mintContractIndex[_contract];
        mintContracts.length--;
    }
    function removeChild(uint256 _fromTokenId, address _childContract, uint256 _childTokenId) private {
        uint256 lastTokenIndex = childTokens[_fromTokenId][_childContract].length - 1;
        uint256 lastToken = childTokens[_fromTokenId][_childContract][lastTokenIndex];
        if (_childTokenId != lastToken) {
            uint256 tokenIndex = childTokenIndex[_fromTokenId][_childContract][_childTokenId];
            childTokens[_fromTokenId][_childContract][tokenIndex] = lastToken;
            childTokenIndex[_fromTokenId][_childContract][lastToken] = tokenIndex;
        }
        childTokens[_fromTokenId][_childContract].length--;
        delete childTokenIndex[_fromTokenId][_childContract][_childTokenId];
        delete childTokenOwner[_childContract][_childTokenId];
        if (lastTokenIndex == 0) {
            uint256 lastContractIndex = childContracts[_fromTokenId].length - 1;
            address lastContract = childContracts[_fromTokenId][lastContractIndex];
            if (_childContract != lastContract) {
                uint256 contractIndex = childContractIndex[_fromTokenId][_childContract];
                childContracts[_fromTokenId][contractIndex] = lastContract;
                childContractIndex[_fromTokenId][lastContract] = contractIndex;
            }
            childContracts[_fromTokenId].length--;
            delete childContractIndex[_fromTokenId][_childContract];
        }
    }
    function safeTransferChild(uint256 _fromTokenId, address _to, address _childContract, uint256 _childTokenId) external {
        uint256 tokenId = childTokenOwner[_childContract][_childTokenId];
        require(tokenId != 0, "Child token does not exist");
        require(_fromTokenId == tokenId - 1, "_fromTokenId does not own the child token.");
        require(_to != address(0), "_to cannot be 0 address.");
        address rootOwner = address(rootOwnerOf(_fromTokenId));
        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] ||
        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_fromTokenId] == msg.sender, "msg.sender not rootOwner/operator/approved.");
        removeChild(_fromTokenId, _childContract, _childTokenId);
        ERC721(_childContract).safeTransferFrom(this, _to, _childTokenId);
        emit TransferChild(_fromTokenId, _to, _childContract, _childTokenId);
    }
    function safeTransferChild(uint256 _fromTokenId, address _to, address _childContract, uint256 _childTokenId, bytes _data) external {
        uint256 tokenId = childTokenOwner[_childContract][_childTokenId];
        require(tokenId != 0, "Child token does not exist");
        require(_fromTokenId == tokenId - 1, "_fromTokenId does not own the child token.");
        require(_to != address(0), "_to cannot be 0 address.");
        address rootOwner = address(rootOwnerOf(_fromTokenId));
        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] ||
        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_fromTokenId] == msg.sender, "msg.sender not rootOwner/operator/approved.");
        removeChild(_fromTokenId, _childContract, _childTokenId);
        ERC721(_childContract).safeTransferFrom(this, _to, _childTokenId, _data);
        emit TransferChild(_fromTokenId, _to, _childContract, _childTokenId);
    }
    function transferChild(uint256 _fromTokenId, address _to, address _childContract, uint256 _childTokenId) external {
        uint256 tokenId = childTokenOwner[_childContract][_childTokenId];
        require(tokenId != 0, "Child token does not exist");
        require(_fromTokenId == tokenId - 1, "_fromTokenId does not own the child token.");
        require(_to != address(0), "_to cannot be 0 address.");
        address rootOwner = address(rootOwnerOf(_fromTokenId));
        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] ||
        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_fromTokenId] == msg.sender, "msg.sender not rootOwner/operator/approved.");
        removeChild(_fromTokenId, _childContract, _childTokenId);
        bytes memory calldata = abi.encodeWithSelector(0x095ea7b3, this, _childTokenId);
        assembly {
            let success := call(gas, _childContract, 0, add(calldata, 0x20), mload(calldata), calldata, 0)
        }
        ERC721(_childContract).transferFrom(this, _to, _childTokenId);
        emit TransferChild(_fromTokenId, _to, _childContract, _childTokenId);
    }
    function transferChildToParent(uint256 _fromTokenId, address _toContract, uint256 _toTokenId, address _childContract, uint256 _childTokenId, bytes _data) external {
        uint256 tokenId = childTokenOwner[_childContract][_childTokenId];
        require(tokenId != 0, "Child token does not exist");
        require(_fromTokenId == tokenId - 1, "_fromTokenId does not own the child token.");
        require(_toContract != address(0), "_toContract cannot be 0 address.");
        address rootOwner = address(rootOwnerOf(_fromTokenId));
        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] ||
        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_fromTokenId] == msg.sender, "msg.sender not rootOwner/operator/approved.");
        removeChild(_fromTokenId, _childContract, _childTokenId);
        ERC998ERC721BottomUp(_childContract).transferToParent(address(this), _toContract, _toTokenId, _childTokenId, _data);
        emit TransferChild(_fromTokenId, _toContract, _childContract, _childTokenId);
    }
    function removeERC20(uint256 _tokenId, address _erc20Contract, uint256 _value) private {
        if (_value == 0) {
            return;
        }
        uint256 erc20Balance = erc20Balances[_tokenId][_erc20Contract];
        require(erc20Balance >= _value, "Not enough token available to transfer.");
        uint256 newERC20Balance = erc20Balance - _value;
        erc20Balances[_tokenId][_erc20Contract] = newERC20Balance;
        if (newERC20Balance == 0) {
            uint256 lastContractIndex = erc20Contracts[_tokenId].length - 1;
            address lastContract = erc20Contracts[_tokenId][lastContractIndex];
            if (_erc20Contract != lastContract) {
                uint256 contractIndex = erc20ContractIndex[_tokenId][_erc20Contract];
                erc20Contracts[_tokenId][contractIndex] = lastContract;
                erc20ContractIndex[_tokenId][lastContract] = contractIndex;
            }
            erc20Contracts[_tokenId].length--;
            delete erc20ContractIndex[_tokenId][_erc20Contract];
        }
    }
    function transferERC20(uint256 _tokenId, address _to, address _erc20Contract, uint256 _value) external {
        address rootOwner = address(rootOwnerOf(_tokenId));
        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] ||
        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId] == msg.sender, "msg.sender not rootOwner/operator/approved.");
        require(_to != address(0), "_to cannot be 0 address");
        removeERC20(_tokenId, _erc20Contract, _value);
        require(ERC20AndERC223(_erc20Contract).transfer(_to, _value), "ERC20 transfer failed.");
        emit TransferERC20(_tokenId, _to, _erc20Contract, _value);
    }
    function transferERC223(uint256 _tokenId, address _to, address _erc223Contract, uint256 _value, bytes _data) external {
        address rootOwner = address(rootOwnerOf(_tokenId));
        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] ||
        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId] == msg.sender, "msg.sender not rootOwner/operator/approved.");
        require(_to != address(0), "_to cannot be 0 address");
        removeERC20(_tokenId, _erc223Contract, _value);
        require(ERC20AndERC223(_erc223Contract).transfer(_to, _value, _data), "ERC223 transfer failed.");
        emit TransferERC20(_tokenId, _to, _erc223Contract, _value);
    }
    function getERC20(address _from, uint256 _tokenId, address _erc20Contract, uint256 _value) public {
        bool allowed = _from == msg.sender;
        if (!allowed) {
            uint256 remaining;
            bytes memory calldata = abi.encodeWithSelector(0xdd62ed3e, _from, msg.sender);
            bool callSuccess;
            assembly {
                callSuccess := staticcall(gas, _erc20Contract, add(calldata, 0x20), mload(calldata), calldata, 0x20)
                if callSuccess {
                    remaining := mload(calldata)
                }
            }
            require(callSuccess, "call to allowance failed");
            require(remaining >= _value, "Value greater than remaining");
            allowed = true;
        }
        require(allowed, "msg.sender not _from and has no allowance.");
        erc20Received(_from, _tokenId, _erc20Contract, _value);
        require(ERC20AndERC223(_erc20Contract).transferFrom(_from, this, _value), "ERC20 transfer failed.");
    }
    function erc20Received(address _from, uint256 _tokenId, address _erc20Contract, uint256 _value) private {
        require(address(mokens[_tokenId].data) != address(0), "_tokenId does not exist.");
        if (_value == 0) {
            return;
        }
        uint256 erc20Balance = erc20Balances[_tokenId][_erc20Contract];
        if (erc20Balance == 0) {
            erc20ContractIndex[_tokenId][_erc20Contract] = erc20Contracts[_tokenId].length;
            erc20Contracts[_tokenId].push(_erc20Contract);
        }
        erc20Balances[_tokenId][_erc20Contract] += _value;
        emit ReceivedERC20(_from, _tokenId, _erc20Contract, _value);
    }
    function tokenFallback(address _from, uint256 _value, bytes _data) external {
        require(_data.length > 0, "_data must contain the uint256 tokenId to transfer the token to.");
        require(isContract(msg.sender), "msg.sender is not a contract");
        uint256 tokenId;
        assembly {
            tokenId := calldataload(132)
        }
        if (_data.length < 32) {
            tokenId = tokenId >> 256 - _data.length * 8;
        }
        erc20Received(_from, tokenId, msg.sender, _value);
    }
    function removeBottomUpChild(address _fromContract, uint256 _fromTokenId, uint256 _tokenId) internal {
        uint256 lastChildTokenIndex = parentToChildTokenIds[_fromContract][_fromTokenId].length - 1;
        uint256 lastChildTokenId = parentToChildTokenIds[_fromContract][_fromTokenId][lastChildTokenIndex];
        if (_tokenId != lastChildTokenId) {
            uint256 currentChildTokenIndex = tokenIdToChildTokenIdsIndex[_tokenId];
            parentToChildTokenIds[_fromContract][_fromTokenId][currentChildTokenIndex] = uint32(lastChildTokenId);
            tokenIdToChildTokenIdsIndex[lastChildTokenId] = currentChildTokenIndex;
        }
        parentToChildTokenIds[_fromContract][_fromTokenId].length--;
    }
    function transferFromParent(address _fromContract, uint256 _fromTokenId, address _to, uint256 _tokenId, bytes _data) external {
        require(_fromContract != address(0), "_fromContract cannot be the 0 address.");
        require(_to != address(0), "_to cannot be the 0 address.");
        uint256 data = mokens[_tokenId].data;
        require(address(data) == _fromContract, "The tokenId is not owned by _fromContract.");
        uint256 parentTokenId = mokens[_tokenId].parentTokenId;
        require(parentTokenId != 0, "Token does not have a parent token.");
        require(parentTokenId - 1 == _fromTokenId, "tokenId not owned by _fromTokenId");
        address rootOwner = address(rootOwnerOf(_tokenId));
        address approvedAddress = rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] ||
        approvedAddress == msg.sender, "msg.sender not rootOwner/operator/approved.");
        if (approvedAddress != address(0)) {
            delete rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
            emit Approval(rootOwner, address(0), _tokenId);
        }
        mokens[_tokenId].parentTokenId = 0;
        removeBottomUpChild(_fromContract, _fromTokenId, _tokenId);
        delete tokenIdToChildTokenIdsIndex[_tokenId];
        _transferFrom(data, _to, _tokenId);
        if (isContract(_to)) {
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _fromContract, _tokenId, _data);
            require(retval == ERC721_RECEIVED_NEW, "Contract cannot receive ERC721 token.");
        }
        emit TransferFromParent(_fromContract, _fromTokenId, _tokenId);
    }
    function transferToParent(address _from, address _toContract, uint256 _toTokenId, uint256 _tokenId, bytes _data) external {
        require(_from != address(0), "_from cannot be the 0 address.");
        require(_toContract != address(0), "toContract cannot be 0");
        uint256 data = mokens[_tokenId].data;
        require(address(data) == _from, "The tokenId is not owned by _from.");
        require(mokens[_tokenId].parentTokenId == 0, "Cannot transfer from address when owned by a token.");
        childApproved(_from, _tokenId);
        uint256 parentTokenId = _toTokenId + 1;
        assert(parentTokenId > _toTokenId);
        mokens[_tokenId].parentTokenId = parentTokenId;
        uint256 index = parentToChildTokenIds[_toContract][_toTokenId].length;
        parentToChildTokenIds[_toContract][_toTokenId].push(uint32(_tokenId));
        tokenIdToChildTokenIdsIndex[_tokenId] = index;
        _transferFrom(data, _toContract, _tokenId);
        require(ERC721(_toContract).ownerOf(_toTokenId) != address(0), "_toTokenId does not exist");
        emit TransferToParent(_toContract, _toTokenId, _tokenId);
    }
    function transferAsChild(address _fromContract, uint256 _fromTokenId, address _toContract, uint256 _toTokenId, uint256 _tokenId, bytes _data) external {
        require(_fromContract != address(0), "_fromContract cannot be the 0 address.");
        require(_toContract != address(0), "_toContract cannot be the 0 address.");
        uint256 data = mokens[_tokenId].data;
        require(address(data) == _fromContract, "The tokenId is not owned by _fromContract.");
        uint256 parentTokenId = mokens[_tokenId].parentTokenId;
        require(parentTokenId != 0, "Token does not have a parent token.");
        require(parentTokenId - 1 == _fromTokenId, "tokenId not owned by _fromTokenId");
        address rootOwner = address(rootOwnerOf(_tokenId));
        address approvedAddress = rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] ||
        approvedAddress == msg.sender, "msg.sender not rootOwner/operator/approved.");
        if (approvedAddress != address(0)) {
            delete rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
            emit Approval(rootOwner, address(0), _tokenId);
        }
        removeBottomUpChild(_fromContract, _fromTokenId, _tokenId);
        parentTokenId = _toTokenId + 1;
        assert(parentTokenId > _toTokenId);
        mokens[_tokenId].parentTokenId = parentTokenId;
        uint256 index = parentToChildTokenIds[_toContract][_toTokenId].length;
        parentToChildTokenIds[_toContract][_toTokenId].push(uint32(_tokenId));
        tokenIdToChildTokenIdsIndex[_tokenId] = index;
        _transferFrom(data, _toContract, _tokenId);
        require(ERC721(_toContract).ownerOf(_toTokenId) != address(0), "_toTokenId does not exist");
        emit Transfer(_fromContract, _toContract, _tokenId);
        emit TransferFromParent(_fromContract, _fromTokenId, _tokenId);
        emit TransferToParent(_toContract, _toTokenId, _tokenId);
    }
    function getStateHash(uint256 _tokenId) public view returns (bytes32 stateHash) {
        address[] memory childContracts_ = childContracts[_tokenId];
        stateHash = keccak256(childContracts_);
        uint256 length = childContracts_.length;
        uint256 i;
        for (i = 0; i < length; i++) {
            stateHash = keccak256(stateHash, childTokens[_tokenId][childContracts_[i]]);
        }
        address[] memory erc20Contracts_ = erc20Contracts[_tokenId];
        stateHash = keccak256(erc20Contracts_);
        length = erc20Contracts_.length;
        for (i = 0; i < length; i++) {
            stateHash = keccak256(stateHash, erc20Balances[_tokenId][erc20Contracts_[i]]);
        }
        uint256 linkHash = mokens[_tokenId].data & MOKEN_LINK_HASH_MASK;
        return keccak256(stateHash, linkHash);
    }
}
