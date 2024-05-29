contract Registrar {
    ENS public ens;
    bytes32 public rootNode;
    mapping (bytes32 => Entry) _entries;
    mapping (address => mapping (bytes32 => Deed)) public sealedBids;
    enum Mode { Open, Auction, Owned, Forbidden, Reveal, NotYetAvailable }
    uint32 constant totalAuctionLength = 5 days;
    uint32 constant revealPeriod = 48 hours;
    uint32 public constant launchLength = 8 weeks;
    uint constant minPrice = 0.01 ether;
    uint public registryStarted;
    event AuctionStarted(bytes32 indexed hash, uint registrationDate);
    event NewBid(bytes32 indexed hash, address indexed bidder, uint deposit);
    event BidRevealed(bytes32 indexed hash, address indexed owner, uint value, uint8 status);
    event HashRegistered(bytes32 indexed hash, address indexed owner, uint value, uint registrationDate);
    event HashReleased(bytes32 indexed hash, uint value);
    event HashInvalidated(bytes32 indexed hash, string indexed name, uint value, uint registrationDate);
    struct Entry {
        Deed deed;
        uint registrationDate;
        uint value;
        uint highestBid;
    }
    modifier inState(bytes32 _hash, Mode _state) {
        require(state(_hash) == _state);
        _;
    }
    modifier onlyOwner(bytes32 _hash) {
        require(state(_hash) == Mode.Owned && msg.sender == _entries[_hash].deed.owner());
        _;
    }
    modifier registryOpen() {
        require(now >= registryStarted && now <= registryStarted + 4 years && ens.owner(rootNode) == address(this));
        _;
    }
    function Registrar(ENS _ens, bytes32 _rootNode, uint _startDate) public {
        ens = _ens;
        rootNode = _rootNode;
        registryStarted = _startDate > 0 ? _startDate : now;
    }
    function startAuction(bytes32 _hash) public registryOpen() {
        Mode mode = state(_hash);
        if (mode == Mode.Auction) return;
        require(mode == Mode.Open);
        Entry storage newAuction = _entries[_hash];
        newAuction.registrationDate = now + totalAuctionLength;
        newAuction.value = 0;
        newAuction.highestBid = 0;
        AuctionStarted(_hash, newAuction.registrationDate);
    }
    function startAuctions(bytes32[] _hashes) public {
        for (uint i = 0; i < _hashes.length; i ++) {
            startAuction(_hashes[i]);
        }
    }
    function newBid(bytes32 sealedBid) public payable {
        require(address(sealedBids[msg.sender][sealedBid]) == 0x0);
        require(msg.value >= minPrice);
        Deed newBid = (new Deed).value(msg.value)(msg.sender);
        sealedBids[msg.sender][sealedBid] = newBid;
        NewBid(sealedBid, msg.sender, msg.value);
    }
    function startAuctionsAndBid(bytes32[] hashes, bytes32 sealedBid) public payable {
        startAuctions(hashes);
        newBid(sealedBid);
    }
    function unsealBid(bytes32 _hash, uint _value, bytes32 _salt) public {
        bytes32 seal = shaBid(_hash, msg.sender, _value, _salt);
        Deed bid = sealedBids[msg.sender][seal];
        require(address(bid) != 0);
        sealedBids[msg.sender][seal] = Deed(0);
        Entry storage h = _entries[_hash];
        uint value = min(_value, bid.value());
        bid.setBalance(value, true);
        var auctionState = state(_hash);
        if (auctionState == Mode.Owned) {
            bid.closeDeed(5);
            BidRevealed(_hash, msg.sender, value, 1);
        } else if (auctionState != Mode.Reveal) {
            revert();
        } else if (value < minPrice || bid.creationDate() > h.registrationDate - revealPeriod) {
            bid.closeDeed(995);
            BidRevealed(_hash, msg.sender, value, 0);
        } else if (value > h.highestBid) {
            if (address(h.deed) != 0) {
                Deed previousWinner = h.deed;
                previousWinner.closeDeed(995);
            }
            h.value = h.highestBid;   
            h.highestBid = value;
            h.deed = bid;
            BidRevealed(_hash, msg.sender, value, 2);
        } else if (value > h.value) {
            h.value = value;
            bid.closeDeed(995);
            BidRevealed(_hash, msg.sender, value, 3);
        } else {
            bid.closeDeed(995);
            BidRevealed(_hash, msg.sender, value, 4);
        }
    }
    function cancelBid(address bidder, bytes32 seal) public {
        Deed bid = sealedBids[bidder][seal];
        require(address(bid) != 0 && now >= bid.creationDate() + totalAuctionLength + 2 weeks);
        bid.setOwner(msg.sender);
        bid.closeDeed(5);
        sealedBids[bidder][seal] = Deed(0);
        BidRevealed(seal, bidder, 0, 5);
    }
    function finalizeAuction(bytes32 _hash) public onlyOwner(_hash) {
        Entry storage h = _entries[_hash];
        h.value =  max(h.value, minPrice);
        h.deed.setBalance(h.value, true);
        trySetSubnodeOwner(_hash, h.deed.owner());
        HashRegistered(_hash, h.deed.owner(), h.value, h.registrationDate);
    }
    function transfer(bytes32 _hash, address newOwner) public onlyOwner(_hash) {
        require(newOwner != 0);
        Entry storage h = _entries[_hash];
        h.deed.setOwner(newOwner);
        trySetSubnodeOwner(_hash, newOwner);
    }
    function releaseDeed(bytes32 _hash) public onlyOwner(_hash) {
        Entry storage h = _entries[_hash];
        Deed deedContract = h.deed;
        require(now >= h.registrationDate + 1 years || ens.owner(rootNode) != address(this));
        h.value = 0;
        h.highestBid = 0;
        h.deed = Deed(0);
        _tryEraseSingleNode(_hash);
        deedContract.closeDeed(1000);
        HashReleased(_hash, h.value);        
    }
    function invalidateName(string unhashedName) public inState(keccak256(unhashedName), Mode.Owned) {
        require(strlen(unhashedName) <= 6);
        bytes32 hash = keccak256(unhashedName);
        Entry storage h = _entries[hash];
        _tryEraseSingleNode(hash);
        if (address(h.deed) != 0) {
            h.value = max(h.value, minPrice);
            h.deed.setBalance(h.value/2, false);
            h.deed.setOwner(msg.sender);
            h.deed.closeDeed(1000);
        }
        HashInvalidated(hash, unhashedName, h.value, h.registrationDate);
        h.value = 0;
        h.highestBid = 0;
        h.deed = Deed(0);
    }
    function eraseNode(bytes32[] labels) public {
        require(labels.length != 0);
        require(state(labels[labels.length - 1]) != Mode.Owned);
        _eraseNodeHierarchy(labels.length - 1, labels, rootNode);
    }
    function transferRegistrars(bytes32 _hash) public onlyOwner(_hash) {
        address registrar = ens.owner(rootNode);
        require(registrar != address(this));
        Entry storage h = _entries[_hash];
        h.deed.setRegistrar(registrar);
        Registrar(registrar).acceptRegistrarTransfer(_hash, h.deed, h.registrationDate);
        h.deed = Deed(0);
        h.registrationDate = 0;
        h.value = 0;
        h.highestBid = 0;
    }
    function acceptRegistrarTransfer(bytes32 hash, Deed deed, uint registrationDate) public {
        hash; deed; registrationDate;  
    }
    function state(bytes32 _hash) public view returns (Mode) {
        Entry storage entry = _entries[_hash];
        if (!isAllowed(_hash, now)) {
            return Mode.NotYetAvailable;
        } else if (now < entry.registrationDate) {
            if (now < entry.registrationDate - revealPeriod) {
                return Mode.Auction;
            } else {
                return Mode.Reveal;
            }
        } else {
            if (entry.highestBid == 0) {
                return Mode.Open;
            } else {
                return Mode.Owned;
            }
        }
    }
    function entries(bytes32 _hash) public view returns (Mode, address, uint, uint, uint) {
        Entry storage h = _entries[_hash];
        return (state(_hash), h.deed, h.registrationDate, h.value, h.highestBid);
    }
    function isAllowed(bytes32 _hash, uint _timestamp) public view returns (bool allowed) {
        return _timestamp > getAllowedTime(_hash);
    }
    function getAllowedTime(bytes32 _hash) public view returns (uint) {
        return registryStarted + ((launchLength * (uint(_hash) >> 128)) >> 128);
    }
    function shaBid(bytes32 hash, address owner, uint value, bytes32 salt) public pure returns (bytes32) {
        return keccak256(hash, owner, value, salt);
    }
    function _tryEraseSingleNode(bytes32 label) internal {
        if (ens.owner(rootNode) == address(this)) {
            ens.setSubnodeOwner(rootNode, label, address(this));
            bytes32 node = keccak256(rootNode, label);
            ens.setResolver(node, 0);
            ens.setOwner(node, 0);
        }
    }
    function _eraseNodeHierarchy(uint idx, bytes32[] labels, bytes32 node) internal {
        ens.setSubnodeOwner(node, labels[idx], address(this));
        node = keccak256(node, labels[idx]);
        if (idx > 0) {
            _eraseNodeHierarchy(idx - 1, labels, node);
        }
        ens.setResolver(node, 0);
        ens.setOwner(node, 0);
    }
    function trySetSubnodeOwner(bytes32 _hash, address _newOwner) internal {
        if (ens.owner(rootNode) == address(this))
            ens.setSubnodeOwner(rootNode, _hash, _newOwner);
    }
    function max(uint a, uint b) internal pure returns (uint) {
        if (a > b)
            return a;
        else
            return b;
    }
    function min(uint a, uint b) internal pure returns (uint) {
        if (a < b)
            return a;
        else
            return b;
    }
    function strlen(string s) internal pure returns (uint) {
        s;  
        uint ptr;
        uint end;
        assembly {
            ptr := add(s, 1)
            end := add(mload(s), ptr)
        }
        for (uint len = 0; ptr < end; len++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if (b < 0xE0) {
                ptr += 2;
            } else if (b < 0xF0) {
                ptr += 3;
            } else if (b < 0xF8) {
                ptr += 4;
            } else if (b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
        return len;
    }
}
