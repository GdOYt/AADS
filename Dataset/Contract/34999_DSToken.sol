contract DSToken is DSTokenBase(0), DSStop {
    mapping (address => mapping (address => bool)) _trusted;
    bytes32  public  symbol;
    uint256  public  decimals = 18;  
    function DSToken(bytes32 symbol_) {
        symbol = symbol_;
    }
    event Trust(address indexed src, address indexed guy, bool wat);
    event Mint(address indexed guy, uint wad);
    event Burn(address indexed guy, uint wad);
    function trusted(address src, address guy) constant returns (bool) {
        return _trusted[src][guy];
    }
    function trust(address guy, bool wat) stoppable {
        _trusted[msg.sender][guy] = wat;
        Trust(msg.sender, guy, wat);
    }
    function approve(address guy, uint wad) stoppable returns (bool) {
        return super.approve(guy, wad);
    }
    function transferFrom(address src, address dst, uint wad)
        stoppable
        returns (bool)
    {
        if (src != msg.sender && !_trusted[src][msg.sender]) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);
        Transfer(src, dst, wad);
        return true;
    }
    function push(address dst, uint wad) {
        transferFrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) {
        transferFrom(src, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) {
        transferFrom(src, dst, wad);
    }
    function mint(uint wad) {
        mint(msg.sender, wad);
    }
    function burn(uint wad) {
        burn(msg.sender, wad);
    }
    function mint(address guy, uint wad) auth stoppable {
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        Mint(guy, wad);
    }
    function burn(address guy, uint wad) auth stoppable {
        if (guy != msg.sender && !_trusted[guy][msg.sender]) {
            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
        }
        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        Burn(guy, wad);
    }
    bytes32   public  name = "";
    function setName(bytes32 name_) auth {
        name = name_;
    }
}
