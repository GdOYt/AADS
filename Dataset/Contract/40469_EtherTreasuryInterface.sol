contract EtherTreasuryInterface {
    function withdraw(address _to, uint _value) returns(bool);
    function withdrawWithReference(address _to, uint _value, string _reference) returns(bool);
}
