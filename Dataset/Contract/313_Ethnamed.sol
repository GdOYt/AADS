contract Ethnamed is DEXified {
    using SafeMath for uint;
    using StringHelper for string;
    struct Name {
        string record;
        address owner;
        uint expires;
        uint balance;
    }
    function withdraw(address _to) public {
        require(msg.sender == issuer); 
        _to.transfer(address(this).balance);
    }
    mapping (string => Name) internal registry;
    mapping (bytes32 => string) internal lookup;
    function resolve(string _name) public view returns (string) {
        return registry[_name].record;
    }
    function whois(bytes32 _hash) public view returns (string) {
        return lookup[_hash];
    }
    function transferOwnership(string _name, address _to) public {
        require(registry[_name].owner == msg.sender);
        registry[_name].owner = _to;
    }
    function removeName(string _name) internal {
        Name storage item = registry[_name];
        bytes32 hash = keccak256(item.record);
        delete registry[_name];
        delete lookup[hash];
    }
    function removeExpiredName(string _name) public {
        require(registry[_name].expires < now);
        removeName(_name);
    }
    function removeNameByOwner(string _name) public {
        Name storage item = registry[_name];
        require(item.owner == msg.sender);
        removeName(_name);
    }
    function sendTo(string _name) public payable {
        if (registry[_name].owner == address(0)) {
            registry[_name].balance = registry[_name].balance.add(msg.value);
        }
        else {
            registry[_name].owner.transfer(msg.value);
        }
    }
    function setupCore(string _name, string _record, address _owner, uint _life) internal {
        Name storage item = registry[_name];
        require(item.owner == msg.sender || item.owner == 0x0);
        item.record = _record;
        item.owner = _owner;
        if (item.balance > 0) {
            item.owner.transfer(item.balance);
            item.balance = 0;
        }
        item.expires = now + _life;
        bytes32 hash = keccak256(_record);
        lookup[hash] = _name;
    }
    function setupViaAuthority(
        string _length,
        string _name,
        string _record,
        string _blockExpiry,
        address _owner,
        uint8 _v, 
        bytes32 _r, 
        bytes32 _s,
        uint _life
    ) internal {
        require(_blockExpiry.stringToUint() >= block.number);
        require(ecrecover(keccak256("\x19Ethereum Signed Message:\n", _length, _name, "r=", _record, "e=", _blockExpiry), _v, _r, _s) == issuer);
        setupCore(_name, _record, _owner, _life);
    }
    function setOrUpdateRecord2(
        string _length,
        string _name,
        string _record,
        string _blockExpiry,
        address _owner,
        uint8 _v, 
        bytes32 _r, 
        bytes32 _s
    ) public {
        Contributor storage contributor = contributors[msg.sender];
        require(contributor.balance >= tokenPrice);
        contributor.balance = contributor.balance.sub(tokenPrice);
        uint life = 48 weeks;
        setupViaAuthority(_length, _name, _record, _blockExpiry, _owner, _v, _r, _s, life);   
    }
    function setOrUpdateRecord(
        string _length,
        string _name,
        string _record,
        string _blockExpiry,
        address _owner,
        uint8 _v, 
        bytes32 _r, 
        bytes32 _s
    ) public payable {
        uint life = msg.value == 0.01  ether ?  48 weeks : 
                    msg.value == 0.008 ether ?  24 weeks :
                    msg.value == 0.006 ether ?  12 weeks :
                    msg.value == 0.002 ether ?  4  weeks :
                    0;
        require(life > 0);
        setupViaAuthority(_length, _name, _record, _blockExpiry, _owner, _v, _r, _s, life);
    }
}
