contract RBACMintableToken is MintableToken, RBAC {
    string public constant ROLE_MINTER = "minter";
    address[] internal minters;
    modifier hasMintPermission() {
        checkRole(msg.sender, ROLE_MINTER);
        _;
    }
    function addMinter(address minter) onlyOwner public {
        if (!hasRole(minter, ROLE_MINTER))
            minters.push(minter);
        addRole(minter, ROLE_MINTER);
    }
    function removeMinter(address minter) onlyOwner public {
        removeRole(minter, ROLE_MINTER);
        removeMinterByValue(minter);
    }
    function getNumberOfMinters() onlyOwner public view returns (uint) {
        return minters.length;
    }
    function getMinter(uint _index) onlyOwner public view returns (address) {
        require(_index < minters.length);
        return minters[_index];
    }
    function removeMinterByIndex(uint index) internal {
        require(minters.length > 0);
        if (minters.length > 1) {
            minters[index] = minters[minters.length - 1];
            delete (minters[minters.length - 1]);
        }
        minters.length--;
    }
    function removeMinterByValue(address _client) internal {
        for (uint i = 0; i < minters.length; i++) {
            if (minters[i] == _client) {
                removeMinterByIndex(i);
                break;
            }
        }
    }
}
