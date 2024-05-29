contract Declaration {
    mapping (uint => uint8) statusThreshold;
    mapping (uint8 => mapping (uint8 => uint)) feeDistribution;
    uint[8] thresholds = [
    0, 5000, 35000, 150000, 500000, 2500000, 5000000, 10000000
    ];
    uint[5] referralFees = [50, 30, 20, 10, 5];
    uint[5] serviceFees = [25, 20, 15, 10, 5];
    function Declaration() public {
        setFeeDistributionsAndStatusThresholds();
    }
    function setFeeDistributionsAndStatusThresholds() private {
        setFeeDistributionAndStatusThreshold(0, [12, 8, 5, 2, 1], thresholds[0]);
        setFeeDistributionAndStatusThreshold(1, [16, 10, 6, 3, 2], thresholds[1]);
        setFeeDistributionAndStatusThreshold(2, [20, 12, 8, 4, 2], thresholds[2]);
        setFeeDistributionAndStatusThreshold(3, [25, 15, 10, 5, 3], thresholds[3]);
        setFeeDistributionAndStatusThreshold(4, [30, 18, 12, 6, 3], thresholds[4]);
        setFeeDistributionAndStatusThreshold(5, [35, 21, 14, 7, 4], thresholds[5]);
        setFeeDistributionAndStatusThreshold(6, [40, 24, 16, 8, 4], thresholds[6]);
        setFeeDistributionAndStatusThreshold(7, [50, 30, 20, 10, 5], thresholds[7]);
    }
    function setFeeDistributionAndStatusThreshold(
        uint8 _st,
        uint8[5] _percentages,
        uint _threshold
    )
    private
    {
        statusThreshold[_threshold] = _st;
        for (uint8 i = 0; i < _percentages.length; i++) {
            feeDistribution[_st][i] = _percentages[i];
        }
    }
}
