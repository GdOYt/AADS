contract LedgerProofVerifyI {
    function external_oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) public;
    function external_oraclize_randomDS_proofVerify(bytes proof, bytes32 queryId, bytes result, string context_name)  public returns (bool);
}
