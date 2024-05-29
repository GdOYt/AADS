contract DSBaseActor {
    bool _ds_mutex;
    modifier mutex() {
        assert(!_ds_mutex);
        _ds_mutex = true;
        _;
        _ds_mutex = false;
    }
    function tryExec( address target, bytes calldata, uint256 value)
			mutex()
            internal
            returns (bool call_ret)
    {
        return target.call.value(value)(calldata);
    }
    function exec( address target, bytes calldata, uint256 value)
             internal
    {
        assert(tryExec(target, calldata, value));
    }
}
