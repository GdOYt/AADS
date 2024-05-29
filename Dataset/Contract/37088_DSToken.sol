contract DSToken is DSTokenBase(0), DSStop {
    bytes32  public  symbol;
    uint256  public  decimals = 18;  
    address  public  generator;
    modifier onlyGenerator {
        if(msg.sender!=generator) throw;
        _;
    }
    function DSToken(bytes32 symbol_) {
        symbol = symbol_;
        generator=msg.sender;
    }
    function transfer(address dst, uint wad) stoppable note returns (bool) {
        return super.transfer(dst, wad);
    }
    function transferFrom(
    address src, address dst, uint wad
    ) stoppable note returns (bool) {
        return super.transferFrom(src, dst, wad);
    }
    function approve(address guy, uint wad) stoppable note returns (bool) {
        return super.approve(guy, wad);
    }
    function push(address dst, uint128 wad) returns (bool) {
        return transfer(dst, wad);
    }
    function pull(address src, uint128 wad) returns (bool) {
        return transferFrom(src, msg.sender, wad);
    }
    function mint(uint128 wad) auth stoppable note {
        _balances[msg.sender] = add(_balances[msg.sender], wad);
        _supply = add(_supply, wad);
    }
    function burn(uint128 wad) auth stoppable note {
        _balances[msg.sender] = sub(_balances[msg.sender], wad);
        _supply = sub(_supply, wad);
    }
    function generatorTransfer(address dst, uint wad) onlyGenerator note returns (bool) {
        return super.transfer(dst, wad);
    }
    bytes32   public  name = "";
    function setName(bytes32 name_) auth {
        name = name_;
    }
}
