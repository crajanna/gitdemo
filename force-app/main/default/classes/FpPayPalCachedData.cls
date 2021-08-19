public without sharing class FpPayPalCachedData {
    public String contractId { get; set; }
    public String transferAmount { get; set; }
    public String fee { get; set; }
    public String recordTypeId { get; set; }
    
    public FpPayPalCachedData(String contractId, String transferAmount, String fee, String recordTypeId ) {
        this.contractId = contractId;
        this.transferAmount = transferAmount;
        this.fee = fee;
        this.recordTypeId  = recordTypeId;
    }
}