contract ArithLib {
    function jdouble(uint _ax, uint _ay, uint _az) constant returns (uint, uint, uint);
    function jadd(uint _ax, uint _ay, uint _az, uint _bx, uint _by, uint _bz) constant returns (uint, uint, uint);
    function jsub(uint _ax, uint _ay, uint _az, uint _bx, uint _by, uint _bz) constant returns (uint, uint, uint);
    function jmul(uint _bx, uint _by, uint _bz, uint _n) constant returns (uint, uint, uint);
    function jexp(uint _b, uint _e, uint _m) constant returns (uint);
    function jrecover_y(uint _x, uint _y_bit) constant returns (uint);
    function jdecompose(uint _q0, uint _q1, uint _q2) constant returns (uint, uint);
    function isbit(uint _data, uint _bit) constant returns (uint);
    function hash_pubkey_to_pubkey(uint _pub1, uint _pub2) constant returns (uint, uint);
}
