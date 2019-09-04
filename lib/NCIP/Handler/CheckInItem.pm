package NCIP::Handler::CheckInItem;

=head1

  NCIP::Handler::CheckInItem

=head1 SYNOPSIS

    Not to be called directly, NCIP::Handler will pick the appropriate Handler 
    object, given a message type

=head1 FUNCTIONS

=cut

use Modern::Perl;

use NCIP::Handler;

our @ISA = qw(NCIP::Handler);

sub handle {
    my $self   = shift;
    my $xmldoc = shift;
    if ($xmldoc) {
        my $root   = $xmldoc->documentElement();
        my $xpc    = $self->xpc();

        my $config = $self->{config}->{koha};

        my $itemid;
        if ( $self->{ncip_version} == 1 ) {
            $itemid = $xpc->findnodes( '//ItemIdentifierValue', $root );
        } else {
            $itemid = $xpc->findnodes( '//ns:ItemIdentifierValue', $root );
        }

        # check in the item
        my $branch = undef;    # where the hell do we get this from???
        my ( $from, $to ) = $self->get_agencies($xmldoc);
        
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare(
            "SELECT * FROM items WHERE barcode = ?
                ");

        $sth->execute($itemid);
        my $data_br = $sth->fetchrow_hashref;
        
        my $sthiss = $dbh->prepare(
            "select cardnumber as cardnumber from borrowers where borrowernumber in (Select borrowernumber from issues where itemnumber in (select itemnumber from items where barcode = ?))");

        $sthiss->execute($itemid);
        my $data_iss = $sthiss->fetchrow_hashref;                    
      

        my $checkin = $self->ils->checkin(
            {
                barcode => $itemid,
                branch  => $branch,
                config  => $config,
            }
        );
        
        

        if ( $checkin->{success} ) {
            return $self->render_output(
                'response.tt',
                {
                    message_type => 'CheckInItemResponse',
                    barcode      => $itemid,
                    from_agency  => $to,
                    to_agency    => $from,
                    elements     => $self->get_user_elements($xmldoc),
                    checkin      => $checkin,
                    branch       => $data_br->{'homebranch'},
                    cardnumber   => $data_iss->{'cardnumber'},
                }
            );
        }
        else {
            return $self->render_output(
                'problem.tt',
                {
                    message_type => 'CheckInItemResponse',
                    problems     => $checkin->{problems},

                }
            );
        }
    }
}

1;
