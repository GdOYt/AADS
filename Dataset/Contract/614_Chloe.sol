contract Chloe is ERC223 {
    string public constant name = "Shuhan Liao";
    string public constant symbol = "Chloe";
    uint8 public constant decimals = 0;
    string public message;
    constructor()
        public {
        totalSupply_ = 2;
        balances[owner] = totalSupply_;
        emit Transfer(0x0, owner, totalSupply_);
        message = "Happy Valentines Day!";
    }
}
