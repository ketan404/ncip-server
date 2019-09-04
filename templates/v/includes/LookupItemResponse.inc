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
    <AgencyId Scheme="">[% branch %]</AgencyId>
    <ItemIdentifierType Scheme="">Barcode</ItemIdentifierType>        
    <ItemIdentifierValue>[% item.barcode | xml %]</ItemIdentifierValue>    
</ItemId>
[% IF element.textContent == 'Hold Queue Length' %]
<DateRecalled>1900-01-01T00:00:00</DateRecalled>
<HoldPickupDate>[% waitingdate %]T00:00:00</HoldPickupDate>
[% END %]
<ItemOptionalFields>
    [% FOREACH element IN elements %]
        [% IF element.textContent == 'Bibliographic Description' %]
            <BibliographicDescription>
                <Author>[% item.biblio.author |xml %]</Author>

                <BibliographicItemId>
                    <BibliographicItemIdentifier>[% item.biblio.isbn %]</BibliographicItemIdentifier>
                    <BibliographicItemIdentifierCode Scheme="">ISBN</BibliographicItemIdentifierCode>
                </BibliographicItemId>

                <BibliographicRecordId>
                    <BibliographicRecordIdentifier>[% item.biblio.lccn %]</BibliographicRecordIdentifier>
                    <BibliographicRecordIdentifierCode Scheme="">LCCN</BibliographicRecordIdentifierCode>
                </BibliographicRecordId>

                <Edition>[% item.biblio.editionstatement  |xml %]</Edition>
                <PlaceOfPublication>[% item.biblio.place |xml %]</PlaceOfPublication>
                <PublicationDate>[% item.biblio.copyrightdate %]</PublicationDate>
                <Publisher>[% item.biblio.publishercode |xml %]</Publisher>
                <Title>[% item.biblio.title |xml %]</Title>
                [%- FILTER collapse -%]
                    <BibliographicLevel Scheme="">
                        [%- FILTER trim -%]
                            [%- SWITCH item.record.leader.substr(7, 1) -%]
                            [%- CASE 'a' -%]
                                Monographic component part
                            [%- CASE 'b' -%]
                                Serial component part
                            [%- CASE 'c' -%]
                                Collection
                            [%- CASE 'd' -%]
                                Subunit
                            [%- CASE 'i' -%]
                                Integrating resource
                            [%- CASE 'm' -%]
                                Monograph
                            [%- CASE 's' -%] 
                                Serial
                            [%- END -%]
                        [%- END -%]
                    </BibliographicLevel>
                [%- END -%]
                <Language>[% item.record.field('008').data.substr(35,3) %]</Language>
                [%- FILTER collapse -%]
                    <MediumType>[% item.itype %]</MediumType>
                [%- END -%]
            </BibliographicDescription>
        [% END %]

        [% IF element.textContent == 'Circulation Status' %]
                            [% IF item.onloan %]
                                <CirculationStatus>On Loan</CirculationStatus>
                            [% ELSIF item.itemlost %]
                                <CirculationStatus>Lost</CirculationStatus>
                            [% ELSIF item.damaged %]
                                <CirculationStatus>Missing</CirculationStatus>
                            [% ELSIF item.notforlaon > 0 %]
                               <CirculationStatus>Not Available</CirculationStatus>
                            [% ELSIF item.notforlaon < 0 %]
                                <CirculationStatus>On Order</CirculationStatus>
                            [% ELSIF item.hold.found %]
                                <CirculationStatus>Available For Pickup</CirculationStatus>
                            [% ELSIF item.transfers.size %]
                                <CirculationStatus>In Transit Between Library Locations</CirculationStatus>
                            [% ELSE %]
                                <CirculationStatus>On Shelf</CirculationStatus>
                            [% END %]
        [% END %]

        [% IF element.textContent == 'Hold Queue Length' %]
            <HoldQueueLength>[% item.holds.size %]</HoldQueueLength>
        [% END %]
        [% IF element.textContent == 'Item Description' %]
            <ItemDescription>
            <CallNumber>[% item.itemcallnumber |xml %]</CallNumber>
            <CopyNumber>[% item.itemcopynumber |xml %]</CopyNumber>
           </ItemDescription>
        [% END %]
    [% END %]
<ItemUseRestrictionType Scheme="" />    
    <Location>
      <LocationType>Location</LocationType>
      <LocationName>
        <LocationNameInstance>
          <LocationNameLevel>0</LocationNameLevel>
          <LocationNameValue>[% item.location |xml %]</LocationNameValue>
        </LocationNameInstance>
      </LocationName>
    </Location>
         <Ext>
                <Price>[% item.price %]</Price>
                <PublicationDate>[% item.biblio.copyrightdate |xml %]</PublicationDate>
                <ItemCategory>[% item.itype %]</ItemCategory>
        </Ext>        
<ItemTransaction />
  </ItemOptionalFields>
 [% IF item.onloan %]
    <ItemTransaction>
            <CurrentBorrower>
                <UserId>
                    <AgencyId>[% branch %]</AgencyId>
                    <ItemIdentifierType Scheme="">Barcode</ItemIdentifierType>
                    <UserIdentifierValue>[% cardnumber %]</UserIdentifierValue>
                </UserId>
                <Ext>
                    <DateDue>[% item.onloan %]T23:59:59</DateDue>
                </Ext>
            </CurrentBorrower>
        </ItemTransaction>
        [% END %]
  [% FOREACH resr IN resrs %]
    <ItemTransaction>
            <CurrentRequester>
                <UserId>
                    <AgencyId>[% item.homebranch %]</AgencyId>
                    <UserIdentifierValue>[% resr.cardnumber %]</UserIdentifierValue>
     </UserId>
</CurrentRequester>
        </ItemTransaction>
[% END %]

