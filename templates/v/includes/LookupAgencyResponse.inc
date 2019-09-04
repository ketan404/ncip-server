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
<AgencyId Scheme="">[% branch %]</AgencyId>
<OrganizationNameInformation>
    <OrganizationNameType>BranchName</OrganizationNameType>
    <OrganizationName>[% branchname | xml %]</OrganizationName>
</OrganizationNameInformation>
