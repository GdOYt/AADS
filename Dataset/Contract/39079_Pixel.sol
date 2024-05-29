contract Pixel is Owned, HumanStandardToken {
  uint32 public size = 1000;
  uint32 public size2 = size*size;
  mapping (uint32 => uint24) public pixels;
  mapping (uint32 => address) public owners;
  event Set(address indexed _from, uint32[] _xys, uint24[] _rgbs);
  event Unset(address indexed _from, uint32[] _xys);
  function Pixel() HumanStandardToken(size2, "Pixel", 0, "PXL") {
  }
  function set(uint32[] _xys, uint24[] _rgbs) publicMethod() {
    address _from = msg.sender;
    require(_xys.length == _rgbs.length);
    require(balances[_from] >= _xys.length);
    uint32 _xy; uint24 _rgb;
    for (uint i = 0; i < _xys.length; i++) {
      _xy = _xys[i];
      _rgb = _rgbs[i];
      require(_xy < size2);
      require(owners[_xy] == 0);
      owners[_xy] = _from;
      pixels[_xy] = _rgb;
    }
    balances[_from] -= _xys.length;
    Set(_from, _xys, _rgbs);
  }
  function unset(uint32[] _xys) publicMethod() {
    address _from = msg.sender;
    uint32 _xy;
    for (uint i = 0; i < _xys.length; i++) {
      _xy = _xys[i];
      require(owners[_xy] == _from);
      balances[_from] += 1;
      owners[_xy] = 0;
      pixels[_xy] = 0;
    }
    Unset(_from, _xys);
  }
  function row(uint32 _y) constant returns (uint24[1000], address[1000]) {
    uint32 _start = _y * size;
    uint24[1000] memory rgbs;
    address[1000] memory addrs;
    for (uint32 i = 0; i < 1000; i++) {
      rgbs[i] = pixels[_start + i];
      addrs[i] = owners[_start + i];
    }
    return (rgbs, addrs);
  }
}
