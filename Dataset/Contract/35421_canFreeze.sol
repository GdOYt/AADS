contract canFreeze is owned { 
    bool public frozen=false;
    modifier LockIfFrozen() {
        if (!frozen){
            _;
        }
    }
    function Freeze() onlyOwner {
        frozen=true;
    }
}
