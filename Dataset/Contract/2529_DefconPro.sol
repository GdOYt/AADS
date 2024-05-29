contract DefconPro is Ownable {
  event Defcon(uint64 blockNumber, uint16 defconLevel);
  uint16 public defcon = 5; 
  modifier defcon4() { 
    require(defcon > 4);
    _;
  }
  modifier defcon3() {
    require(defcon > 3);
    _;
  }
   modifier defcon2() {
    require(defcon > 2);
    _;
  }
  modifier defcon1() { 
    require(defcon > 1);
    _;
  }
  function setDefconLevel(uint16 _defcon) onlyOwner public {
    defcon = _defcon;
    Defcon(uint64(block.number), _defcon);
  }
}
