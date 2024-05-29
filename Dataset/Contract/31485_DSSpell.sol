contract DSSpell is DSExec, DSNote {
    address public whom;
    uint256 public mana;
    bytes   public data;
    bool    public done;
    function DSSpell(address whom_, uint256 mana_, bytes data_) public {
        whom = whom_;
        mana = mana_;
        data = data_;
    }
    function cast() public note {
        require( !done );
        exec(whom, data, mana);
        done = true;
    }
}
