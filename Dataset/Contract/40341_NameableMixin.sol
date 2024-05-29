contract NameableMixin {
    uint constant minimumNameLength = 1;
    uint constant maximumNameLength = 25;
    string constant nameDataPrefix = "NAME:";
    function validateNameInternal(string _name) constant internal
    returns (bool allowed) {
        bytes memory nameBytes = bytes(_name);
        uint lengthBytes = nameBytes.length;
        if (lengthBytes < minimumNameLength ||
            lengthBytes > maximumNameLength) {
            return false;
        }
        bool foundNonPunctuation = false;
        for (uint i = 0; i < lengthBytes; i++) {
            byte b = nameBytes[i];
            if (
                (b >= 48 && b <= 57) ||  
                (b >= 65 && b <= 90) ||  
                (b >= 97 && b <= 122)    
            ) {
                foundNonPunctuation = true;
                continue;
            }
            if (
                b == 32 ||  
                b == 33 ||  
                b == 40 ||  
                b == 41 ||  
                b == 45 ||  
                b == 46 ||  
                b == 95     
            ) {
                continue;
            }
            return false;
        }
        return foundNonPunctuation;
    }
    function extractNameFromData(bytes _data) constant internal
    returns (string extractedName) {
        uint expectedPrefixLength = (bytes(nameDataPrefix)).length;
        if (_data.length < expectedPrefixLength) {
            throw;
        }
        uint i;
        for (i = 0; i < expectedPrefixLength; i++) {
            if ((bytes(nameDataPrefix))[i] != _data[i]) {
                throw;
            }
        }
        uint payloadLength = _data.length - expectedPrefixLength;
        if (payloadLength < minimumNameLength ||
            payloadLength > maximumNameLength) {
            throw;
        }
        string memory name = new string(payloadLength);
        for (i = 0; i < payloadLength; i++) {
            (bytes(name))[i] = _data[expectedPrefixLength + i];
        }
        return name;
    }
    function computeNameFuzzyHash(string _name) constant internal
    returns (uint fuzzyHash) {
        bytes memory nameBytes = bytes(_name);
        uint h = 0;
        uint len = nameBytes.length;
        if (len > maximumNameLength) {
            len = maximumNameLength;
        }
        for (uint i = 0; i < len; i++) {
            uint mul = 128;
            byte b = nameBytes[i];
            uint ub = uint(b);
            if (b >= 48 && b <= 57) {
                h = h * mul + ub;
            } else if (b >= 65 && b <= 90) {
                h = h * mul + ub;
            } else if (b >= 97 && b <= 122) {
                uint upper = ub - 32;
                h = h * mul + upper;
            } else {
            }
        }
        return h;
    }
}
