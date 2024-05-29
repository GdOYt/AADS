contract Mutex is Owned {
    bool locked = false;
    modifier mutexed {
        if (locked) throw;
        locked = true;
        _;
        locked = false;
    }
    function unMutex() onlyOwner {
        locked = false;
    }
}
