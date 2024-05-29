contract Poker is DSCache {
    function poke(address med, bytes32 wut) auth {
        super.poke(wut);
        assert(med.call(bytes4(sha3("poke()"))));
    }
    function prod(address med, bytes32 wut, uint128 zzz) auth {
        super.prod(wut, zzz);
        assert(med.call(bytes4(sha3("poke()"))));
    }
}
