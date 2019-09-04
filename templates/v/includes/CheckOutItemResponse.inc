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
    <AgencyId Scheme="">[% from_agency | trim%]</AgencyId>
    <ItemIdentifierType Scheme="">Barcode</ItemIdentifierType>
    <ItemIdentifierValue>[% barcode | xml %]</ItemIdentifierValue>
</ItemId>
<UserId>
    <AgencyId Scheme="">[% to_agency | trim %]</AgencyId>
    <UserIdentifierType Scheme="">Barcode</UserIdentifierType>
    <UserIdentifierValue>[% userid | xml %]</UserIdentifierValue>
</UserId>
<DateDue>[% datedue %]+05:30</DateDue>
