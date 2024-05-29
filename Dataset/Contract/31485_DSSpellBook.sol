contract DSSpellBook {
    function make(address whom, uint256 mana, bytes data) public returns (DSSpell) {
        return new DSSpell(whom, mana, data);
    }
}
