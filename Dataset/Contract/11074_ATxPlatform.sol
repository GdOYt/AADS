contract ATxPlatform is Object, Emitter {
    uint constant ATX_PLATFORM_SCOPE = 80000;
    uint constant ATX_PLATFORM_PROXY_ALREADY_EXISTS = ATX_PLATFORM_SCOPE + 1;
    uint constant ATX_PLATFORM_CANNOT_APPLY_TO_ONESELF = ATX_PLATFORM_SCOPE + 2;
    uint constant ATX_PLATFORM_INVALID_VALUE = ATX_PLATFORM_SCOPE + 3;
    uint constant ATX_PLATFORM_INSUFFICIENT_BALANCE = ATX_PLATFORM_SCOPE + 4;
    uint constant ATX_PLATFORM_NOT_ENOUGH_ALLOWANCE = ATX_PLATFORM_SCOPE + 5;
    uint constant ATX_PLATFORM_ASSET_ALREADY_ISSUED = ATX_PLATFORM_SCOPE + 6;
    uint constant ATX_PLATFORM_CANNOT_ISSUE_FIXED_ASSET_WITH_INVALID_VALUE = ATX_PLATFORM_SCOPE + 7;
    uint constant ATX_PLATFORM_CANNOT_REISSUE_FIXED_ASSET = ATX_PLATFORM_SCOPE + 8;
    uint constant ATX_PLATFORM_SUPPLY_OVERFLOW = ATX_PLATFORM_SCOPE + 9;
    uint constant ATX_PLATFORM_NOT_ENOUGH_TOKENS = ATX_PLATFORM_SCOPE + 10;
    uint constant ATX_PLATFORM_INVALID_NEW_OWNER = ATX_PLATFORM_SCOPE + 11;
    uint constant ATX_PLATFORM_ALREADY_TRUSTED = ATX_PLATFORM_SCOPE + 12;
    uint constant ATX_PLATFORM_SHOULD_RECOVER_TO_NEW_ADDRESS = ATX_PLATFORM_SCOPE + 13;
    uint constant ATX_PLATFORM_ASSET_IS_NOT_ISSUED = ATX_PLATFORM_SCOPE + 14;
    uint constant ATX_PLATFORM_INVALID_INVOCATION = ATX_PLATFORM_SCOPE + 15;
    using SafeMath for uint;
    struct Asset {
        uint owner;                        
        uint totalSupply;                  
        string name;                       
        string description;                
        bool isReissuable;                 
        uint8 baseUnit;                    
        mapping(uint => Wallet) wallets;   
        mapping(uint => bool) partowners;  
    }
    struct Wallet {
        uint balance;
        mapping(uint => uint) allowance;
    }
    struct Holder {
        address addr;                     
        mapping(address => bool) trust;   
    }
    uint public holdersCount;
    mapping(uint => Holder) public holders;
    mapping(address => uint) holderIndex;
    bytes32[] public symbols;
    mapping(bytes32 => Asset) public assets;
    mapping(bytes32 => address) public proxies;
    mapping(address => bool) public partowners;
    address public eventsHistory;
    modifier onlyOwner(bytes32 _symbol) {
        if (isOwner(msg.sender, _symbol)) {
            _;
        }
    }
    modifier onlyOneOfOwners(bytes32 _symbol) {
        if (hasAssetRights(msg.sender, _symbol)) {
            _;
        }
    }
    modifier onlyOneOfContractOwners() {
        if (contractOwner == msg.sender || partowners[msg.sender]) {
            _;
        }
    }
    modifier onlyProxy(bytes32 _symbol) {
        if (proxies[_symbol] == msg.sender) {
            _;
        }
    }
    modifier checkTrust(address _from, address _to) {
        if (isTrusted(_from, _to)) {
            _;
        }
    }
    function() payable public {
        revert();
    }
    function trust() external returns (uint) {
        uint fromId = _createHolderId(msg.sender);
        if (msg.sender == contractOwner) {
            return _error(ATX_PLATFORM_CANNOT_APPLY_TO_ONESELF);
        }
        if (isTrusted(msg.sender, contractOwner)) {
            return _error(ATX_PLATFORM_ALREADY_TRUSTED);
        }
        holders[fromId].trust[contractOwner] = true;
        return OK;
    }
    function distrust() external checkTrust(msg.sender, contractOwner) returns (uint) {
        holders[getHolderId(msg.sender)].trust[contractOwner] = false;
        return OK;
    }
    function addPartOwner(address _partowner) external onlyContractOwner returns (uint) {
        partowners[_partowner] = true;
        return OK;
    }
    function removePartOwner(address _partowner) external onlyContractOwner returns (uint) {
        delete partowners[_partowner];
        return OK;
    }
    function setupEventsHistory(address _eventsHistory) external onlyContractOwner returns (uint errorCode) {
        eventsHistory = _eventsHistory;
        return OK;
    }
    function addAssetPartOwner(bytes32 _symbol, address _partowner) external onlyOneOfOwners(_symbol) returns (uint) {
        uint holderId = _createHolderId(_partowner);
        assets[_symbol].partowners[holderId] = true;
        Emitter(eventsHistory).emitOwnershipChange(0x0, _partowner, _symbol);
        return OK;
    }
    function removeAssetPartOwner(bytes32 _symbol, address _partowner) external onlyOneOfOwners(_symbol) returns (uint) {
        uint holderId = getHolderId(_partowner);
        delete assets[_symbol].partowners[holderId];
        Emitter(eventsHistory).emitOwnershipChange(_partowner, 0x0, _symbol);
        return OK;
    }
    function massTransfer(address[] addresses, uint[] values, bytes32 _symbol) external onlyOneOfOwners(_symbol) returns (uint errorCode, uint count) {
        require(addresses.length == values.length);
        require(_symbol != 0x0);
        uint senderId = _createHolderId(msg.sender);
        uint success = 0;
        for (uint idx = 0; idx < addresses.length && msg.gas > 110000; ++idx) {
            uint value = values[idx];
            if (value == 0) {
                _error(ATX_PLATFORM_INVALID_VALUE);
                continue;
            }
            if (_balanceOf(senderId, _symbol) < value) {
                _error(ATX_PLATFORM_INSUFFICIENT_BALANCE);
                continue;
            }
            if (msg.sender == addresses[idx]) {
                _error(ATX_PLATFORM_CANNOT_APPLY_TO_ONESELF);
                continue;
            }
            uint holderId = _createHolderId(addresses[idx]);
            _transferDirect(senderId, holderId, value, _symbol);
            Emitter(eventsHistory).emitTransfer(msg.sender, addresses[idx], _symbol, value, "");
            ++success;
        }
        return (OK, success);
    }
    function symbolsCount() public view returns (uint) {
        return symbols.length;
    }
    function isCreated(bytes32 _symbol) public view returns (bool) {
        return assets[_symbol].owner != 0;
    }
    function baseUnit(bytes32 _symbol) public view returns (uint8) {
        return assets[_symbol].baseUnit;
    }
    function name(bytes32 _symbol) public view returns (string) {
        return assets[_symbol].name;
    }
    function description(bytes32 _symbol) public view returns (string) {
        return assets[_symbol].description;
    }
    function isReissuable(bytes32 _symbol) public view returns (bool) {
        return assets[_symbol].isReissuable;
    }
    function owner(bytes32 _symbol) public view returns (address) {
        return holders[assets[_symbol].owner].addr;
    }
    function isOwner(address _owner, bytes32 _symbol) public view returns (bool) {
        return isCreated(_symbol) && (assets[_symbol].owner == getHolderId(_owner));
    }
    function hasAssetRights(address _owner, bytes32 _symbol) public view returns (bool) {
        uint holderId = getHolderId(_owner);
        return isCreated(_symbol) && (assets[_symbol].owner == holderId || assets[_symbol].partowners[holderId]);
    }
    function totalSupply(bytes32 _symbol) public view returns (uint) {
        return assets[_symbol].totalSupply;
    }
    function balanceOf(address _holder, bytes32 _symbol) public view returns (uint) {
        return _balanceOf(getHolderId(_holder), _symbol);
    }
    function _balanceOf(uint _holderId, bytes32 _symbol) public view returns (uint) {
        return assets[_symbol].wallets[_holderId].balance;
    }
    function _address(uint _holderId) public view returns (address) {
        return holders[_holderId].addr;
    }
    function checkIsAssetPartOwner(bytes32 _symbol, address _partowner) public view returns (bool) {
        require(_partowner != 0x0);
        uint holderId = getHolderId(_partowner);
        return assets[_symbol].partowners[holderId];
    }
    function setProxy(address _proxyAddress, bytes32 _symbol) public onlyOneOfContractOwners returns (uint) {
        if (proxies[_symbol] != 0x0) {
            return ATX_PLATFORM_PROXY_ALREADY_EXISTS;
        }
        proxies[_symbol] = _proxyAddress;
        return OK;
    }
    function getHolderId(address _holder) public view returns (uint) {
        return holderIndex[_holder];
    }
    function proxyTransferWithReference(address _to, uint _value, bytes32 _symbol, string _reference, address _sender) onlyProxy(_symbol) public returns (uint) {
        return _transfer(getHolderId(_sender), _createHolderId(_to), _value, _symbol, _reference, getHolderId(_sender));
    }
    function issueAsset(bytes32 _symbol, uint _value, string _name, string _description, uint8 _baseUnit, bool _isReissuable) public returns (uint) {
        return issueAssetToAddress(_symbol, _value, _name, _description, _baseUnit, _isReissuable, msg.sender);
    }
    function issueAssetToAddress(bytes32 _symbol, uint _value, string _name, string _description, uint8 _baseUnit, bool _isReissuable, address _account) public onlyOneOfContractOwners returns (uint) {
        if (_value == 0 && !_isReissuable) {
            return _error(ATX_PLATFORM_CANNOT_ISSUE_FIXED_ASSET_WITH_INVALID_VALUE);
        }
        if (isCreated(_symbol)) {
            return _error(ATX_PLATFORM_ASSET_ALREADY_ISSUED);
        }
        uint holderId = _createHolderId(_account);
        uint creatorId = _account == msg.sender ? holderId : _createHolderId(msg.sender);
        symbols.push(_symbol);
        assets[_symbol] = Asset(creatorId, _value, _name, _description, _isReissuable, _baseUnit);
        assets[_symbol].wallets[holderId].balance = _value;
        Emitter(eventsHistory).emitIssue(_symbol, _value, _address(holderId));
        return OK;
    }
    function reissueAsset(bytes32 _symbol, uint _value) public onlyOneOfOwners(_symbol) returns (uint) {
        if (_value == 0) {
            return _error(ATX_PLATFORM_INVALID_VALUE);
        }
        Asset storage asset = assets[_symbol];
        if (!asset.isReissuable) {
            return _error(ATX_PLATFORM_CANNOT_REISSUE_FIXED_ASSET);
        }
        if (asset.totalSupply + _value < asset.totalSupply) {
            return _error(ATX_PLATFORM_SUPPLY_OVERFLOW);
        }
        uint holderId = getHolderId(msg.sender);
        asset.wallets[holderId].balance = asset.wallets[holderId].balance.add(_value);
        asset.totalSupply = asset.totalSupply.add(_value);
        Emitter(eventsHistory).emitIssue(_symbol, _value, _address(holderId));
        _proxyTransferEvent(0, holderId, _value, _symbol);
        return OK;
    }
    function revokeAsset(bytes32 _symbol, uint _value) public returns (uint) {
        if (_value == 0) {
            return _error(ATX_PLATFORM_INVALID_VALUE);
        }
        Asset storage asset = assets[_symbol];
        uint holderId = getHolderId(msg.sender);
        if (asset.wallets[holderId].balance < _value) {
            return _error(ATX_PLATFORM_NOT_ENOUGH_TOKENS);
        }
        asset.wallets[holderId].balance = asset.wallets[holderId].balance.sub(_value);
        asset.totalSupply = asset.totalSupply.sub(_value);
        Emitter(eventsHistory).emitRevoke(_symbol, _value, _address(holderId));
        _proxyTransferEvent(holderId, 0, _value, _symbol);
        return OK;
    }
    function changeOwnership(bytes32 _symbol, address _newOwner) public onlyOwner(_symbol) returns (uint) {
        if (_newOwner == 0x0) {
            return _error(ATX_PLATFORM_INVALID_NEW_OWNER);
        }
        Asset storage asset = assets[_symbol];
        uint newOwnerId = _createHolderId(_newOwner);
        if (asset.owner == newOwnerId) {
            return _error(ATX_PLATFORM_CANNOT_APPLY_TO_ONESELF);
        }
        address oldOwner = _address(asset.owner);
        asset.owner = newOwnerId;
        Emitter(eventsHistory).emitOwnershipChange(oldOwner, _newOwner, _symbol);
        return OK;
    }
    function isTrusted(address _from, address _to) public view returns (bool) {
        return holders[getHolderId(_from)].trust[_to];
    }
    function recover(address _from, address _to) checkTrust(_from, msg.sender) public onlyContractOwner returns (uint errorCode) {
        address from = holders[getHolderId(_from)].addr;
        holders[getHolderId(_from)].addr = _to;
        holderIndex[_to] = getHolderId(_from);
        Emitter(eventsHistory).emitRecovery(from, _to, msg.sender);
        return OK;
    }
    function proxyApprove(address _spender, uint _value, bytes32 _symbol, address _sender) public onlyProxy(_symbol) returns (uint) {
        return _approve(_createHolderId(_spender), _value, _symbol, _createHolderId(_sender));
    }
    function allowance(address _from, address _spender, bytes32 _symbol) public view returns (uint) {
        return _allowance(getHolderId(_from), getHolderId(_spender), _symbol);
    }
    function proxyTransferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string _reference, address _sender) public onlyProxy(_symbol) returns (uint) {
        return _transfer(getHolderId(_from), _createHolderId(_to), _value, _symbol, _reference, getHolderId(_sender));
    }
    function _transferDirect(uint _fromId, uint _toId, uint _value, bytes32 _symbol) internal {
        assets[_symbol].wallets[_fromId].balance = assets[_symbol].wallets[_fromId].balance.sub(_value);
        assets[_symbol].wallets[_toId].balance = assets[_symbol].wallets[_toId].balance.add(_value);
    }
    function _transfer(uint _fromId, uint _toId, uint _value, bytes32 _symbol, string _reference, uint _senderId) internal returns (uint) {
        if (_fromId == _toId) {
            return _error(ATX_PLATFORM_CANNOT_APPLY_TO_ONESELF);
        }
        if (_value == 0) {
            return _error(ATX_PLATFORM_INVALID_VALUE);
        }
        if (_balanceOf(_fromId, _symbol) < _value) {
            return _error(ATX_PLATFORM_INSUFFICIENT_BALANCE);
        }
        if (_fromId != _senderId && _allowance(_fromId, _senderId, _symbol) < _value) {
            return _error(ATX_PLATFORM_NOT_ENOUGH_ALLOWANCE);
        }
        _transferDirect(_fromId, _toId, _value, _symbol);
        if (_fromId != _senderId) {
            assets[_symbol].wallets[_fromId].allowance[_senderId] = assets[_symbol].wallets[_fromId].allowance[_senderId].sub(_value);
        }
        Emitter(eventsHistory).emitTransfer(_address(_fromId), _address(_toId), _symbol, _value, _reference);
        _proxyTransferEvent(_fromId, _toId, _value, _symbol);
        return OK;
    }
    function _proxyTransferEvent(uint _fromId, uint _toId, uint _value, bytes32 _symbol) internal {
        if (proxies[_symbol] != 0x0) {
            ProxyEventsEmitter(proxies[_symbol]).emitTransfer(_address(_fromId), _address(_toId), _value);
        }
    }
    function _createHolderId(address _holder) internal returns (uint) {
        uint holderId = holderIndex[_holder];
        if (holderId == 0) {
            holderId = ++holdersCount;
            holders[holderId].addr = _holder;
            holderIndex[_holder] = holderId;
        }
        return holderId;
    }
    function _approve(uint _spenderId, uint _value, bytes32 _symbol, uint _senderId) internal returns (uint) {
        if (!isCreated(_symbol)) {
            return _error(ATX_PLATFORM_ASSET_IS_NOT_ISSUED);
        }
        if (_senderId == _spenderId) {
            return _error(ATX_PLATFORM_CANNOT_APPLY_TO_ONESELF);
        }
        if (assets[_symbol].wallets[_senderId].allowance[_spenderId] != 0 && _value != 0) {
            return _error(ATX_PLATFORM_INVALID_INVOCATION);
        }
        assets[_symbol].wallets[_senderId].allowance[_spenderId] = _value;
        Emitter(eventsHistory).emitApprove(_address(_senderId), _address(_spenderId), _symbol, _value);
        if (proxies[_symbol] != 0x0) {
            ProxyEventsEmitter(proxies[_symbol]).emitApprove(_address(_senderId), _address(_spenderId), _value);
        }
        return OK;
    }
    function _allowance(uint _fromId, uint _toId, bytes32 _symbol) internal view returns (uint) {
        return assets[_symbol].wallets[_fromId].allowance[_toId];
    }
    function _error(uint _errorCode) internal returns (uint) {
        Emitter(eventsHistory).emitError(_errorCode);
        return _errorCode;
    }
}
