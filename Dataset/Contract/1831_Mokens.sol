contract Mokens is AbstractMokens {
    constructor(address _delegate) public {
        delegate = _delegate;
        blockNum = block.number;
        owner = msg.sender;
        bytes32 startingEra = "Genesis";
        bytes memory calldata = abi.encodeWithSignature("startNextEra(bytes32)", startingEra);
        bool callSuccess;
        assembly {
            callSuccess := delegatecall(gas, _delegate, add(calldata, 0x20), mload(calldata), 0, 0)
        }
        require(callSuccess);
        supportedInterfaces[0x01ffc9a7] = true;
        supportedInterfaces[0x80ac58cd] = true;
        supportedInterfaces[0x5b5e139f] = true;
        supportedInterfaces[0x780e9d63] = true;
        supportedInterfaces[0x150b7a02] = true;
        supportedInterfaces[0xf0b9e5ba] = true;
        supportedInterfaces[0x1efdf36a] = true;
        supportedInterfaces[0xa344afe4] = true;
        supportedInterfaces[0x7294ffed] = true;
        supportedInterfaces[0xc5fd96cd] = true;
        supportedInterfaces[0xa1b23002] = true;
        supportedInterfaces[0x8318b539] = true;
    }
    function supportsInterface(bytes4 _interfaceID) external view returns (bool) {
        return supportedInterfaces[_interfaceID];
    }
    function balanceOf(address _tokenOwner) external view returns (uint256 totalMokensOwned) {
        require(_tokenOwner != address(0), "Moken owner cannot be the 0 address.");
        return ownedTokens[_tokenOwner].length;
    }
    function ownerOf(uint256 _tokenId) external view returns (address tokenOwner) {
        tokenOwner = address(mokens[_tokenId].data);
        require(tokenOwner != address(0), "The tokenId does not exist.");
        return tokenOwner;
    }
    function approve(address _approved, uint256 _tokenId) external {
        address rootOwner = address(rootOwnerOf(_tokenId));
        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender], "Must be rootOwner or operator.");
        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId] = _approved;
        emit Approval(rootOwner, _approved, _tokenId);
    }
    function getApproved(uint256 _tokenId) external view returns (address approvedAddress) {
        address rootOwner = address(rootOwnerOf(_tokenId));
        return rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
    }
    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != address(0), "Operator cannot be 0 address.");
        tokenOwnerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }
    function isApprovedForAll(address _tokenOwner, address _operator) external view returns (bool approved) {
        return tokenOwnerToOperators[_tokenOwner][_operator];
    }
    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        require(_from != address(0), "_from cannot be the 0 address.");
        require(_to != address(0), "_to cannot be the 0 address.");
        uint256 data = mokens[_tokenId].data;
        require(address(data) == _from, "The tokenId is not owned by _from.");
        require(_to != address(this), "Cannot transfer to this contract.");
        require(mokens[_tokenId].parentTokenId == 0, "Cannot transfer from an address when owned by a token.");
        childApproved(_from, _tokenId);
        _transferFrom(data, _to, _tokenId);
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {
        require(_from != address(0), "_from cannot be the 0 address.");
        require(_to != address(0), "_to cannot be the 0 address.");
        uint256 data = mokens[_tokenId].data;
        require(address(data) == _from, "The tokenId is not owned by _from.");
        require(mokens[_tokenId].parentTokenId == 0, "Cannot transfer from an address when owned by a token.");
        childApproved(_from, _tokenId);
        _transferFrom(data, _to, _tokenId);
        if (isContract(_to)) {
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, "");
            require(retval == ERC721_RECEIVED_NEW, "_to contract cannot receive ERC721 tokens.");
        }
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external {
        require(_from != address(0), "_from cannot be the 0 address.");
        require(_to != address(0), "_to cannot be the 0 address.");
        uint256 data = mokens[_tokenId].data;
        require(address(data) == _from, "The tokenId is not owned by _from.");
        require(mokens[_tokenId].parentTokenId == 0, "Cannot transfer from an address when owned by a token.");
        childApproved(_from, _tokenId);
        _transferFrom(data, _to, _tokenId);
        if (_to == address(this)) {
            require(_data.length > 0, "_data must contain the uint256 tokenId to transfer the token to.");
            uint256 toTokenId;
            assembly {toTokenId := calldataload(164)}
            if (_data.length < 32) {
                toTokenId = toTokenId >> 256 - _data.length * 8;
            }
            receiveChild(_from, toTokenId, _to, _tokenId);
        }
        else {
            if (isContract(_to)) {
                bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
                require(retval == ERC721_RECEIVED_NEW, "_to contract cannot receive ERC721 tokens.");
            }
        }
    }
    function exists(uint256 _tokenId) external view returns (bool) {
        return _tokenId < mokensLength;
    }
    function tokenOfOwnerByIndex(address _tokenOwner, uint256 _index) external view returns (uint256 tokenId) {
        require(_index < ownedTokens[_tokenOwner].length, "_tokenOwner does not own a moken at this index.");
        return ownedTokens[_tokenOwner][_index];
    }
    function totalSupply() external view returns (uint256 totalMokens) {
        return mokensLength;
    }
    function tokenByIndex(uint256 _index) external view returns (uint256 tokenId) {
        require(_index < mokensLength, "A tokenId at index does not exist.");
        return _index;
    }
    function name() external pure returns (string) {
        return "Mokens";
    }
    function symbol() external pure returns (string) {
        return "MKN";
    }
    function eraByIndex(uint256 _index) external view returns (bytes32 era) {
        require(_index < eraLength, "No era at this index.");
        return eras[_index];
    }
    function eraByName(bytes32 _eraName) external view returns (uint256 indexOfEra) {
        uint256 index = eraIndex[_eraName];
        require(index != 0, "No era exists with this name.");
        return index - 1;
    }
    function currentEra() external view returns (bytes32 era) {
        return eras[eraLength - 1];
    }
    function currentEraIndex() external view returns (uint256 indexOfEra) {
        return eraLength - 1;
    }
    function eraExists(bytes32 _eraName) external view returns (bool) {
        return eraIndex[_eraName] != 0;
    }
    function totalEras() external view returns (uint256 totalEras_) {
        return eraLength;
    }
    event Mint(
        address indexed mintContract,
        address indexed owner,
        bytes32 indexed era,
        string mokenName,
        bytes32 data,
        uint256 tokenId,
        bytes32 currencyName,
        uint256 price
    );
    event MintPriceChange(
        uint256 mintPrice
    );
    function mintData() external view returns (uint256 mokensLength_, uint256 mintStepPrice_, uint256 mintPriceOffset_) {
        return (mokensLength, mintStepPrice, mintPriceOffset);
    }
    function mintPrice() external view returns (uint256) {
        return (mokensLength * mintStepPrice) - mintPriceOffset;
    }
    function mint(address _tokenOwner, string _mokenName, bytes32 _linkHash) external payable returns (uint256 tokenId) {
        require(_tokenOwner != address(0), "Owner cannot be the 0 address.");
        tokenId = mokensLength++;
        require(tokenId < MAX_MOKENS, "Only 4,294,967,296 mokens can be created.");
        uint256 mintStepPrice_ = mintStepPrice;
        uint256 mintPriceBuffer_ = mintPriceBuffer;
        uint256 currentMintPrice = (tokenId * mintStepPrice_) - mintPriceOffset;
        uint256 pricePaid = currentMintPrice;
        if (msg.value < currentMintPrice) {
            require(mintPriceBuffer_ > currentMintPrice || msg.value > currentMintPrice - mintPriceBuffer_, "Paid ether is lower than mint price.");
            pricePaid = msg.value;
        }
        string memory lowerMokenName = validateAndLower(_mokenName);
        require(tokenByName_[lowerMokenName] == 0, "Moken name already exists.");
        uint256 eraIndex_ = eraLength - 1;
        uint256 ownedTokensIndex = ownedTokens[_tokenOwner].length;
        require(ownedTokensIndex < MAX_OWNER_MOKENS, "An single owner address cannot possess more than 65,536 mokens.");
        uint256 data = uint256(_linkHash) & MOKEN_LINK_HASH_MASK | eraIndex_ << 176 | ownedTokensIndex << 160 | uint160(_tokenOwner);
        mokens[tokenId].name = _mokenName;
        mokens[tokenId].data = data;
        tokenByName_[lowerMokenName] = tokenId + 1;
        ownedTokens[_tokenOwner].push(uint32(tokenId));
        emit Transfer(address(0), _tokenOwner, tokenId);
        emit Mint(this, _tokenOwner, eras[eraIndex_], _mokenName, bytes32(data), tokenId, "Ether", pricePaid);
        emit MintPriceChange(currentMintPrice + mintStepPrice_);
        if (msg.value > currentMintPrice) {
            msg.sender.transfer(msg.value - currentMintPrice);
        }
        return tokenId;
    }
    function isMintContract(address _contract) public view returns (bool) {
        return mintContractIndex[_contract] != 0;
    }
    function totalMintContracts() external view returns (uint256 totalMintContracts_) {
        return mintContracts.length;
    }
    function mintContractByIndex(uint256 index) external view returns (address contract_) {
        require(index < mintContracts.length, "Contract index does not exist.");
        return mintContracts[index];
    }
    function contractMint(address _tokenOwner, string _mokenName, bytes32 _linkHash, bytes32 _currencyName, uint256 _pricePaid) external returns (uint256 tokenId) {
        require(_tokenOwner != address(0), "Token owner cannot be the 0 address.");
        require(isMintContract(msg.sender), "Not an approved mint contract.");
        tokenId = mokensLength++;
        uint256 mokensLength_ = tokenId + 1;
        require(tokenId < MAX_MOKENS, "Only 4,294,967,296 mokens can be created.");
        string memory lowerMokenName = validateAndLower(_mokenName);
        require(tokenByName_[lowerMokenName] == 0, "Moken name already exists.");
        uint256 eraIndex_ = eraLength - 1;
        uint256 ownedTokensIndex = ownedTokens[_tokenOwner].length;
        require(ownedTokensIndex < MAX_OWNER_MOKENS, "An single token owner address cannot possess more than 65,536 mokens.");
        uint256 data = uint256(_linkHash) & MOKEN_LINK_HASH_MASK | eraIndex_ << 176 | ownedTokensIndex << 160 | uint160(_tokenOwner);
        mokens[tokenId].name = _mokenName;
        mokens[tokenId].data = data;
        tokenByName_[lowerMokenName] = mokensLength_;
        ownedTokens[_tokenOwner].push(uint32(tokenId));
        emit Transfer(address(0), _tokenOwner, tokenId);
        emit Mint(msg.sender, _tokenOwner, eras[eraIndex_], _mokenName, bytes32(data), tokenId, _currencyName, _pricePaid);
        emit MintPriceChange((mokensLength_ * mintStepPrice) - mintPriceOffset);
        return tokenId;
    }
    function validateAndLower(string _s) private pure returns (string mokenName) {
        assembly {
            let len := mload(_s)
            let p := add(_s, 0x20)
            if eq(len, 0) {
                revert(0, 0)
            }
            if gt(len, 100) {
                revert(0, 0)
            }
            let b := byte(0, mload(add(_s, 0x20)))
            if lt(b, 0x21) {
                revert(0, 0)
            }
            b := byte(0, mload(add(p, sub(len, 1))))
            if lt(b, 0x21) {
                revert(0, 0)
            }
            for {let end := add(p, len)}
            lt(p, end)
            {p := add(p, 1)}
            {
                b := byte(0, mload(p))
                if lt(b, 0x5b) {
                    if gt(b, 0x40) {
                        mstore8(p, add(b, 32))
                    }
                }
            }
        }
        return _s;
    }
    function mokenNameExists(string _mokenName) external view returns (bool) {
        return tokenByName_[validateAndLower(_mokenName)] != 0;
    }
    function mokenId(string _mokenName) external view returns (uint256 tokenId) {
        tokenId = tokenByName_[validateAndLower(_mokenName)];
        require(tokenId != 0, "No moken exists with this name.");
        return tokenId - 1;
    }
    function mokenData(uint256 _tokenId) external view returns (bytes32 data) {
        data = bytes32(mokens[_tokenId].data);
        require(data != 0, "The tokenId does not exist.");
        return data;
    }
    function eraFromMokenData(bytes32 _data) public view returns (bytes32 era) {
        return eras[uint256(_data) >> 176 & UINT16_MASK];
    }
    function eraFromMokenData(uint256 _data) public view returns (bytes32 era) {
        return eras[_data >> 176 & UINT16_MASK];
    }
    function mokenEra(uint256 _tokenId) external view returns (bytes32 era) {
        uint256 data = mokens[_tokenId].data;
        require(data != 0, "The tokenId does not exist.");
        return eraFromMokenData(data);
    }
    function moken(uint256 _tokenId) external view
    returns (string memory mokenName, bytes32 era, bytes32 data, address tokenOwner) {
        data = bytes32(mokens[_tokenId].data);
        require(data != 0, "The tokenId does not exist.");
        return (
        mokens[_tokenId].name,
        eraFromMokenData(data),
        data,
        address(data)
        );
    }
    function mokenBytes32(uint256 _tokenId) external view
    returns (bytes32 mokenNameBytes32, bytes32 era, bytes32 data, address tokenOwner) {
        data = bytes32(mokens[_tokenId].data);
        require(data != 0, "The tokenId does not exist.");
        bytes memory mokenNameBytes = bytes(mokens[_tokenId].name);
        require(mokenNameBytes.length != 0, "The tokenId does not exist.");
        assembly {
            mokenNameBytes32 := mload(add(mokenNameBytes, 32))
        }
        return (
        mokenNameBytes32,
        eraFromMokenData(data),
        data,
        address(data)
        );
    }
    function mokenNoName(uint256 _tokenId) external view
    returns (bytes32 era, bytes32 data, address tokenOwner) {
        data = bytes32(mokens[_tokenId].data);
        require(data != 0, "The tokenId does not exist.");
        return (
        eraFromMokenData(data),
        data,
        address(data)
        );
    }
    function mokenName(uint256 _tokenId) external view returns (string memory mokenName_) {
        mokenName_ = mokens[_tokenId].name;
        require(bytes(mokenName_).length != 0, "The tokenId does not exist.");
        return mokenName_;
    }
    function mokenNameBytes32(uint256 _tokenId) external view returns (bytes32 mokenNameBytes32_) {
        bytes memory mokenNameBytes = bytes(mokens[_tokenId].name);
        require(mokenNameBytes.length != 0, "The tokenId does not exist.");
        assembly {
            mokenNameBytes32_ := mload(add(mokenNameBytes, 32))
        }
        return mokenNameBytes32_;
    }
    function() external {
        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(gas, sload(delegate_slot), add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 {revert(ptr, size)}
            default {return (ptr, size)}
        }
    }
    function receiveChild(address _from, uint256 _toTokenId, address _childContract, uint256 _childTokenId) internal {
        require(address(mokens[_toTokenId].data) != address(0), "_tokenId does not exist.");
        require(childTokenOwner[_childContract][_childTokenId] == 0, "Child token already received.");
        uint256 childTokensLength = childTokens[_toTokenId][_childContract].length;
        if (childTokensLength == 0) {
            childContractIndex[_toTokenId][_childContract] = childContracts[_toTokenId].length;
            childContracts[_toTokenId].push(_childContract);
        }
        childTokenIndex[_toTokenId][_childContract][_childTokenId] = childTokensLength;
        childTokens[_toTokenId][_childContract].push(_childTokenId);
        childTokenOwner[_childContract][_childTokenId] = _toTokenId + 1;
        emit ReceivedChild(_from, _toTokenId, _childContract, _childTokenId);
    }
    function getChild(address _from, uint256 _toTokenId, address _childContract, uint256 _childTokenId) external {
        receiveChild(_from, _toTokenId, _childContract, _childTokenId);
        require(_from == msg.sender ||
        ERC721(_childContract).getApproved(_childTokenId) == msg.sender ||
        ERC721(_childContract).isApprovedForAll(_from, msg.sender), "msg.sender is not owner/operator/approved for child token.");
        ERC721(_childContract).transferFrom(_from, this, _childTokenId);
    }
    function onERC721Received(address _from, uint256 _childTokenId, bytes _data) external returns (bytes4) {
        require(_data.length > 0, "_data must contain the uint256 tokenId to transfer the child token to.");
        uint256 toTokenId;
        assembly {toTokenId := calldataload(132)}
        if (_data.length < 32) {
            toTokenId = toTokenId >> 256 - _data.length * 8;
        }
        receiveChild(_from, toTokenId, msg.sender, _childTokenId);
        require(ERC721(msg.sender).ownerOf(_childTokenId) != address(0), "Child token not owned.");
        return ERC721_RECEIVED_OLD;
    }
    function onERC721Received(address _operator, address _from, uint256 _childTokenId, bytes _data) external returns (bytes4) {
        require(_data.length > 0, "_data must contain the uint256 tokenId to transfer the child token to.");
        uint256 toTokenId;
        assembly {toTokenId := calldataload(164)}
        if (_data.length < 32) {
            toTokenId = toTokenId >> 256 - _data.length * 8;
        }
        receiveChild(_from, toTokenId, msg.sender, _childTokenId);
        require(ERC721(msg.sender).ownerOf(_childTokenId) != address(0), "Child token not owned.");
        return ERC721_RECEIVED_NEW;
    }
    function ownerOfChild(address _childContract, uint256 _childTokenId) external view returns (bytes32 parentTokenOwner, uint256 parentTokenId) {
        parentTokenId = childTokenOwner[_childContract][_childTokenId];
        require(parentTokenId != 0, "ERC721 token is not a child in this contract.");
        parentTokenId--;
        return (ERC998_MAGIC_VALUE << 224 | bytes32(address(mokens[parentTokenId].data)), parentTokenId);
    }
    function childExists(address _childContract, uint256 _childTokenId) external view returns (bool) {
        return childTokenOwner[_childContract][_childTokenId] != 0;
    }
    function totalChildContracts(uint256 _tokenId) external view returns (uint256) {
        return childContracts[_tokenId].length;
    }
    function childContractByIndex(uint256 _tokenId, uint256 _index) external view returns (address childContract) {
        require(_index < childContracts[_tokenId].length, "Contract address does not exist for this token and index.");
        return childContracts[_tokenId][_index];
    }
    function totalChildTokens(uint256 _tokenId, address _childContract) external view returns (uint256) {
        return childTokens[_tokenId][_childContract].length;
    }
    function childTokenByIndex(uint256 _tokenId, address _childContract, uint256 _index) external view returns (uint256 childTokenId) {
        require(_index < childTokens[_tokenId][_childContract].length, "Token does not own a child token at contract address and index.");
        return childTokens[_tokenId][_childContract][_index];
    }
    function balanceOfERC20(uint256 _tokenId, address _erc20Contract) external view returns (uint256) {
        return erc20Balances[_tokenId][_erc20Contract];
    }
    function erc20ContractByIndex(uint256 _tokenId, uint256 _index) external view returns (address) {
        require(_index < erc20Contracts[_tokenId].length, "Contract address does not exist for this token and index.");
        return erc20Contracts[_tokenId][_index];
    }
    function totalERC20Contracts(uint256 _tokenId) external view returns (uint256) {
        return erc20Contracts[_tokenId].length;
    }
    function tokenOwnerOf(uint256 _tokenId) external view returns (bytes32 tokenOwner, uint256 parentTokenId, bool isParent) {
        address tokenOwnerAddress = address(mokens[_tokenId].data);
        require(tokenOwnerAddress != address(0), "tokenId not found.");
        parentTokenId = mokens[_tokenId].parentTokenId;
        isParent = parentTokenId > 0;
        if (isParent) {
            parentTokenId--;
        }
        return (ERC998_MAGIC_VALUE << 224 | bytes32(tokenOwnerAddress), parentTokenId, isParent);
    }
    function totalChildTokens(address _parentContract, uint256 _parentTokenId) public view returns (uint256) {
        return parentToChildTokenIds[_parentContract][_parentTokenId].length;
    }
    function childTokenByIndex(address _parentContract, uint256 _parentTokenId, uint256 _index) public view returns (uint256) {
        require(parentToChildTokenIds[_parentContract][_parentTokenId].length > _index, "Child not found at index.");
        return parentToChildTokenIds[_parentContract][_parentTokenId][_index];
    }
}
