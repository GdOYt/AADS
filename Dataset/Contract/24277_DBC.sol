contract DBC {
    modifier pre_cond(bool condition) {
        require(condition);
        _;
    }
    modifier post_cond(bool condition) {
        _;
        assert(condition);
    }
    modifier invariant(bool condition) {
        require(condition);
        _;
        assert(condition);
    }
}
