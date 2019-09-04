package NCIP::Handler::LookupItem;

=head1

  NCIP::Handler::LookupItem

=head1 SYNOPSIS

    Not to be called directly, NCIP::Handler will pick the appropriate Handler 
    object, given a message type

=head1 FUNCTIONS

=cut

use Modern::Perl;

use NCIP::Handler;
use NCIP::Item;

our @ISA = qw(NCIP::Handler);

sub handle {
    my $self   = shift;
    my $xmldoc = shift;

    if ($xmldoc) {
        my ($item_id) =
          $xmldoc->getElementsByTagNameNS( $self->namespace(),
            'ItemIdentifierValue' );
        $item_id = $item_id->textContent();

        my $item = NCIP::Item->new(
            {
                itemid => $item_id,
                ils    => $self->ils,
            }
        );

        my $item_data = $item->itemdata();
        
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare(
            "SELECT * FROM items WHERE barcode = ?
                ");

        $sth->execute($item_id);
        my $data_br = $sth->fetchrow_hashref;
        
         my $sthiss = $dbh->prepare(
            "select cardnumber as cardnumber from borrowers where borrowernumber in (Select borrowernumber from issues where itemnumber in (select itemnumber from items where barcode = ?))");

        $sthiss->execute($item_id);
        my $data_iss = $sthiss->fetchrow_hashref;   
       
my $sthiss1 = $dbh->prepare(
            "select biblio.title as title, reserves.reservedate as reservedate, reserves.waitingdate as waitingdate, reserves.expirationdate as expirationdate, items.itype as itype,  borrowers.cardnumber as cardnumber from reserves left join biblio on biblio.biblionumber = reserves.biblionumber left join borrowers on borrowers.borrowernumber = reserves.borrowernumber left join items on items.biblionumber = biblio.biblionumber where reserves.itemnumber in (select itemnumber from items where barcode = ?)");
        $sthiss1->execute($item_id);
        my $data_iss1 = $sthiss1->fetchrow_hashref; 
        
        my $sth_issitems_r = $dbh->prepare("select biblio.title as title, reserves.reservedate as reservedate, reserves.waitingdate as waitingdate, reserves.expirationdate as expirationdate, items.itype as itype,  borrowers.cardnumber as cardnumber from reserves left join biblio on biblio.biblionumber = reserves.biblionumber left join borrowers on borrowers.borrowernumber = reserves.borrowernumber left join items on items.biblionumber = biblio.biblionumber where reserves.itemnumber in (select itemnumber from items where barcode = ?)");
        $sth_issitems_r->execute($item_id);        
        my @value_r;
        while (my $data_issitems_r = $sth_issitems_r->fetchrow_hashref) {                
            push @value_r, $data_issitems_r;
        }  
        

        if ($item_data) {
            my $elements = $self->get_item_elements($xmldoc);
            return $self->render_output(
                'response.tt',
                {
                    message_type => 'LookupItemResponse',
                    item         => $item_data,
                    cardnumber   => $data_iss->{'cardnumber'},
                    branch       => $data_br->{'homebranch'},                
                    elements     => $elements,
                    resrs       => \@value_r,
                     waitingdate   => $data_iss1->{'waitingdate'},
                }
            );
        }
        else {
            return $self->render_output(
                'problem.tt',
                {
                    message_type => 'LookupItemResponse',
                    problems     => [
                        {
                            problem_type    => 'Unknown Item',
                            problem_detail  => 'Item is not known.',
                            problem_element => 'ItemIdentifierValue',
                            problem_value   => $item_id,
                        }
                    ]
                }
            );
        }
    }
}

1;
