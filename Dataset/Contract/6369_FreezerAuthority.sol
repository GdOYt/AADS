contract FreezerAuthority is DSAuthority {
    address[] internal c_freezers;
    bytes4 constant setFreezingSig = bytes4(0x51c3b8a6);
    bytes4 constant transferAndFreezingSig = bytes4(0xb8a1fdb6);
    function canCall(address caller, address, bytes4 sig) public view returns (bool) {
        if (isFreezer(caller) && (sig == setFreezingSig || sig == transferAndFreezingSig)) {
            return true;
        } else {
            return false;
        }
    }
    function addFreezer(address freezer) public {
        int i = indexOf(c_freezers, freezer);
        if (i < 0) {
            c_freezers.push(freezer);
        }
    }
    function removeFreezer(address freezer) public {
        int index = indexOf(c_freezers, freezer);
        if (index >= 0) {
            uint i = uint(index);
            while (i < c_freezers.length - 1) {
                c_freezers[i] = c_freezers[i + 1];
            }
            c_freezers.length--;
        }
    }
    function indexOf(address[] values, address value) internal pure returns (int) {
        uint i = 0;
        while (i < values.length) {
            if (values[i] == value) {
                return int(i);
            }
            i++;
        }
        return int(- 1);
    }
    function isFreezer(address addr) public constant returns (bool) {
        return indexOf(c_freezers, addr) >= 0;
    }
}
