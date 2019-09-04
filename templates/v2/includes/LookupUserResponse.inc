<ResponseHeader>
    <FromSystemId Scheme="" />
    <FromAgencyId>
        <AgencyId Scheme="">[% user.userdata.branchcode %]</AgencyId>
    </FromAgencyId>
    <ToSystemId Scheme="" />
    <ToAgencyId>
        <AgencyId Scheme="">[% user.userdata.branchcode %]</AgencyId>
    </ToAgencyId>
</ResponseHeader>
<UserId>
 <AgencyId Scheme="">[% user.userdata.branchcode %]</AgencyId>
 <UserIdentifierType Scheme="">Barcode</UserIdentifierType>
    [%- SWITCH config.lookup_user_id -%]
    [%- CASE 'same' -%]
	<UserIdentifierValue>[% user_id | xml %]</UserIdentifierValue>
    [%- CASE 'cardnumber' -%]
	<UserIdentifierValue>[% user.userdata.cardnumber | xml %]</UserIdentifierValue>
    [%- CASE 'userid' -%]
	<UserIdentifierValue>[% user.userdata.userid | xml %]</UserIdentifierValue>
    [%- CASE -%]
        ERROR: lookup_user_id is set to an invalid value!
    [%- END -%]
</UserId>

[%# <UserFiscalAccount></UserFiscalAccount>
LoanedItemsCount
LoanedItem
RequestedItemsCount
RequestedItem
-%]

<UserOptionalFields>
    [%- FOREACH element IN elements -%]
        [%- IF element.textContent == 'Name Information' -%]
            <NameInformation>
                <PersonalNameInformation>
                    <StructuredPersonalUserName>
                        <GivenName>[% user.userdata.firstname | xml %]</GivenName>
                        <Surname>[% user.userdata.surname | xml %]</Surname>
                    </StructuredPersonalUserName>
                </PersonalNameInformation>
            </NameInformation>
            <DateOfBirth>[% user.userdata.dateofbirth %]</DateOfBirth>
        [%- END -%]

        [%- IF element.textContent == 'User Address Information' -%]
            <UserAddressInformation>
                <UserAddressRoleType>Home</UserAddressRoleType>
                <PhysicalAddress>
                    <StructuredAddress>
                        <Line1>[% user.userdata.streetnumber | xml %] [% user.userdata.address | xml %]</Line1>

                        [%- IF user.userdata.address2 -%]
                            <Line2>[% user.userdata.address2 | xml %]</Line2>
                        [%- END -%]

                        [%- IF user.userdata.city -%]
                            <Locality>[% user.userdata.city | xml %]</Locality>
                        [%- END -%]

                        [%- IF user.userdata.state -%]
                            <Region>[% user.userdata.state | xml %]</Region>
                        [%- END -%]

                        [%- IF user.userdata.zipcode -%]
                            <PostalCode>[% user.userdata.zipcode | xml %]</PostalCode>
                        [%- END -%]

                        [%- IF user.userdata.country -%]
                            <Country>[% user.userdata.country | xml %]</Country>
                        [%- END -%]
                    </StructuredAddress>
                    <PhysicalAddressType>Postal Address</PhysicalAddressType>
                </PhysicalAddress>
            </UserAddressInformation>

            [%- IF user.userdata.email -%]
                <UserAddressInformation>
                    <UserAddressRoleType>Home</UserAddressRoleType>
                    <ElectronicAddress>
                        <ElectronicAddressType>mailto</ElectronicAddressType>
                        <ElectronicAddressData>[% user.userdata.email %]</ElectronicAddressData>
                    </ElectronicAddress>
                </UserAddressInformation>
            [%- END -%]

            [%- IF user.userdata.phone -%]
                <UserAddressInformation>
                    <UserAddressRoleType>Home</UserAddressRoleType>
                    <ElectronicAddress>
                        <ElectronicAddressType>tel</ElectronicAddressType>
                        <ElectronicAddressData>[% user.userdata.phone %]</ElectronicAddressData>
                    </ElectronicAddress>
                </UserAddressInformation>
            [%- END -%]

            [%- IF user.userdata.phonepro || user.userdata.mobile -%]
                <UserAddressInformation>
                    <UserAddressRoleType>Mobile</UserAddressRoleType>
                    <ElectronicAddress>
                        <ElectronicAddressType>tel</ElectronicAddressType>
                        <ElectronicAddressData>[% user.userdata.phonepro || user.userdata.mobile %]</ElectronicAddressData>
                    </ElectronicAddress>
                </UserAddressInformation>
            [%- END -%]
        [%- END -%]

        [%- IF element.textContent == 'User Privilege' -%]

            <UserPrivilege>
                <AgencyUserPrivilegeType>[% user.userdata.categorycode %]</AgencyUserPrivilegeType>
                    <ValidFromDate>[% user.userdata.dateenrolled %]</ValidFromDate>
                    <ValidToDate>[% user.userdata.dateexpiry %]</ValidToDate>                                    
            </UserPrivilege>

        [%- END -%]
    [%- END -%]

    [%- IF do_not_include_user_identifier_primary_key -%]
        <UserId>
            <UserIdentifierType>Primary Key</UserIdentifierType>
            <UserIdentifierValue>[% user.userdata.borrowernumber %]</UserIdentifierValue>
        </UserId>
    [%- END -%]
    <Ext>
        <UserPhoto>
        [% user.userdata.image %]
        </UserPhoto>
    </Ext>    
</UserOptionalFields>
 <UserFiscalAccount>
      <AccountBalance>
        <CurrencyCode Scheme="">INR</CurrencyCode>
        <MonetaryValue>[% user.userdata.amount %]</MonetaryValue>
      </AccountBalance>
    </UserFiscalAccount>
     <LoanedItemsCount>
      <CirculationStatus Scheme="">On Loan</CirculationStatus>
      <LoanedItemCountValue>[% user.userdata.totalloan %]</LoanedItemCountValue>
      <Ext>
        <Limit>[% user.userdata.maxissueqty %]</Limit>
      </Ext>
    </LoanedItemsCount>
    <RequestedItemsCount>
        [% IF (loan.date_due) %]
        <CirculationStatus Scheme="">On Loan</CirculationStatus>
        [% ELSE %]
        <CirculationStatus Scheme="">On Shelf</CirculationStatus>
        <RequestedItemCountValue>[% user.userdata.reserve %]</RequestedItemCountValue>
        [% END %]
    </RequestedItemsCount>
    [% FOREACH loan IN loans %]
   <LoanedItem>
    <ItemId>
        <AgencyId Scheme="">[% user.userdata.branchcode %]</AgencyId>
        <ItemIdentifierType Scheme="">Barcode</ItemIdentifierType>
        <ItemIdentifierValue>[% loan.barcode %]</ItemIdentifierValue>
    </ItemId>
    <ReminderLevel />
    <DateDue>[% loan.date_due %]T23:59:59</DateDue>
    <Amount>
       <CurrencyCode>INR</CurrencyCode>
       [% IF (loan.amountoutstanding) %]
       <MonetaryValue>[% loan.amountoutstanding %]</MonetaryValue>
       [% ELSE %]
       <MonetaryValue>0</MonetaryValue>
       [% END %]
    </Amount>
    <Title>[% loan.title | xml %]</Title>
    <MediumType Scheme="">[% loan.itype %]</MediumType>
</LoanedItem>
[% END %]
[% FOREACH resr IN resrs %]
<RequestedItem>
    <RequestStatusType>In Process</RequestStatusType>
    <DatePlaced>[% resr.reservedate %]T23:59:59</DatePlaced>
    <PickupDate>[% resr.reservedate %]T23:59:59</PickupDate>
    <PickupExpiryDate>[% resr.reservedate %]T23:59:59</PickupExpiryDate>
    <ReminderLevel />
    <Title>[% resr.title | xml %]</Title>
    <MediumType Scheme="">[% resr.itype %]</MediumType>
    <ItemId>
        <AgencyId Scheme="">[% resr.homebranch %]</AgencyId>
        <ItemIdentifierType Scheme="">Barcode</ItemIdentifierType>
        <ItemIdentifierValue>[% resr.barcode %]</ItemIdentifierValue>
   </ItemId>
</RequestedItem>
[% END %]

    
