<ResponseHeader>
    <FromSystemId Scheme="" />
    <FromAgencyId>
        <AgencyId Scheme="">[% branch %]</AgencyId>
    </FromAgencyId>
    <ToSystemId Scheme="" />
    <ToAgencyId>
        <AgencyId Scheme="">[% branch %]</AgencyId>
    </ToAgencyId>
</ResponseHeader>
<ItemId>
    <AgencyId Scheme="">[% branch | trim%]</AgencyId>
    <ItemIdentifierType>Barcode</ItemIdentifierType>
    <ItemIdentifierValue Scheme="">[% barcode | xml %]</ItemIdentifierValue>
</ItemId>
<UserId>
<AgencyId Scheme="">[% branch %]</AgencyId>
    <UserIdentifierType Scheme="">Barcode</UserIdentifierType>
    <UserIdentifierValue>[% cardnumber %]</UserIdentifierValue>
</UserId>
