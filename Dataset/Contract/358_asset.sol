contract asset is owned {
    using strings for *;
    struct data {
        string link;
        string encryptionType;
        string hashValue;
    }
    data[] dataArray;
    uint dataNum;
    bool public isValid;
    bool public isInit;
    bool public isTradeable;
    uint public price;
    string public remark1;
    string public remark2;
    constructor() public {
        isValid = true;
        isInit = false;
        isTradeable = false;
        price = 0;
        dataNum = 0;
    }
    function initAsset(
        uint dataNumber,
        string linkSet,
        string encryptionTypeSet,
        string hashValueSet) public onlyHolder {
        var links = linkSet.toSlice();
        var encryptionTypes = encryptionTypeSet.toSlice();
        var hashValues = hashValueSet.toSlice();
        var delim = " ".toSlice();
        dataNum = dataNumber;
        require(isInit == false, "The contract has been initialized");
        require(dataNumber >= 1, "The dataNumber should bigger than 1");
        require(dataNumber - 1 == links.count(delim), "The uumber of linkSet error");
        require(dataNumber - 1 == encryptionTypes.count(delim), "The uumber of encryptionTypeSet error");
        require(dataNumber - 1 == hashValues.count(delim), "The uumber of hashValues error");
        isInit = true;
        var empty = "".toSlice();
        for (uint i = 0; i < dataNumber; i++) {
            var link = links.split(delim);
            var encryptionType = encryptionTypes.split(delim);
            var hashValue = hashValues.split(delim);
            require(!encryptionType.empty(), "The encryptionTypeSet data error");
            require(!hashValue.empty(), "The hashValues data error");
            dataArray.push(
                data(link.toString(), encryptionType.toString(), hashValue.toString())
                );
        }
    }
    function getAssetBaseInfo() public view returns (uint _price,
                                                 bool _isTradeable,
                                                 uint _dataNum,
                                                 string _remark1,
                                                 string _remark2) {
        require(isValid == true, "contract is invaild");
        _price = price;
        _isTradeable = isTradeable;
        _dataNum = dataNum;
        _remark1 = remark1;
        _remark2 = remark2;
    }
    function getDataByIndex(uint index) public view returns (string link, string encryptionType, string hashValue) {
        require(isValid == true, "contract is invaild");
        require(index >= 0, "The idx smaller than 0");
        require(index < dataNum, "The idx bigger than dataNum");
        link = dataArray[index].link;
        encryptionType = dataArray[index].encryptionType;
        hashValue = dataArray[index].hashValue;
    }
    function setPrice(uint newPrice) public onlyHolder {
        require(isValid == true, "contract is invaild");
        price = newPrice;
    }
    function setTradeable(bool status) public onlyHolder {
        require(isValid == true, "contract is invaild");
        isTradeable = status;
    }
    function setRemark1(string content) public onlyHolder {
        require(isValid == true, "contract is invaild");
        remark1 = content;
    }
    function setRemark2(string content) public onlyHolder {
        require(isValid == true, "contract is invaild");
        remark2 = content;
    }
    function setDataLink(uint index, string url) public onlyHolder {
        require(isValid == true, "contract is invaild");
        require(index >= 0, "The index smaller than 0");
        require(index < dataNum, "The index bigger than dataNum");
        dataArray[index].link = url;
    }
    function cancelContract() public onlyHolder {
        isValid = false;
    }
    function getDataNum() public view returns (uint num) {
        num = dataNum;
    }
    function transferOwnership(address newHolder, bool status) public onlyHolder {
        holder = newHolder;
        isTradeable = status;
    }
}
