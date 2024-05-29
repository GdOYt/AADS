contract Haltable is Ownable {
    bool public halted = false;
    function Haltable() public {}
    modifier stopIfHalted {
      require(!halted);
      _;
    }
    modifier runIfHalted{
      require(halted);
      _;
    }
    function halt() onlyOwner stopIfHalted public {
        halted = true;
    }
    function unHalt() onlyOwner runIfHalted public {
        halted = false;
    }
}
