contract CarefulSenderMixin {
    uint constant suggestedExtraGasToIncludeWithSends = 23000;
    function carefulSendWithFixedGas(
        address _toAddress,
        uint _valueWei,
        uint _extraGasIncluded
    ) internal returns (bool success) {
        return _toAddress.call.value(_valueWei).gas(_extraGasIncluded)();
    }
}
