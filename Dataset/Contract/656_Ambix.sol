contract Ambix is Ownable {
    address[][] public A;
    uint256[][] public N;
    address[] public B;
    uint256[] public M;
    function appendSource(
        address[] _a,
        uint256[] _n
    ) external onlyOwner {
        require(_a.length == _n.length);
        for (uint256 i = 0; i < _a.length; ++i)
            require(_a[i] != 0);
        A.push(_a);
        N.push(_n);
    }
    function setSink(
        address[] _b,
        uint256[] _m
    ) external onlyOwner{
        require(_b.length == _m.length);
        for (uint256 i = 0; i < _b.length; ++i)
            require(_b[i] != 0);
        B = _b;
        M = _m;
    }
    function run(uint256 _ix) public {
        require(_ix < A.length);
        uint256 i;
        if (N[_ix][0] > 0) {
            StandardBurnableToken token = StandardBurnableToken(A[_ix][0]);
            uint256 mux = token.allowance(msg.sender, this) / N[_ix][0];
            require(mux > 0);
            for (i = 0; i < A[_ix].length; ++i) {
                token = StandardBurnableToken(A[_ix][i]);
                require(token.transferFrom(msg.sender, this, mux * N[_ix][i]));
                token.burn(mux * N[_ix][i]);
            }
            for (i = 0; i < B.length; ++i) {
                token = StandardBurnableToken(B[i]);
                require(token.transfer(msg.sender, M[i] * mux));
            }
        } else {
            require(A[_ix].length == 1 && B.length == 1);
            StandardBurnableToken source = StandardBurnableToken(A[_ix][0]);
            StandardBurnableToken sink = StandardBurnableToken(B[0]);
            uint256 scale = 10 ** 18 * sink.balanceOf(this) / source.totalSupply();
            uint256 allowance = source.allowance(msg.sender, this);
            require(allowance > 0);
            require(source.transferFrom(msg.sender, this, allowance));
            source.burn(allowance);
            uint256 reward = scale * allowance / 10 ** 18;
            require(reward > 0);
            require(sink.transfer(msg.sender, reward));
        }
    }
}
