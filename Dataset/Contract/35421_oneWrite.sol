contract oneWrite {  
  bool written = false;
  function oneWrite() {
    written = false;
  }
  modifier LockIfUnwritten() {
    if (written){
        _;
    }
  }
  modifier writeOnce() {
    if (!written){
        written=true;
        _;
    }
  }
}
