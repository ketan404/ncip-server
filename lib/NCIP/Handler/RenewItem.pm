package NCIP::Handler::RenewItem;

=head1

  NCIP::Handler::RenewItem

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
        my $root = $xmldoc->documentElement();
        my $xpc  = $self->xpc();
        my $userid   = $xpc->findnodes( '//ns:UserIdentifierValue', $root );
        my $itemid   = $xpc->findnodes( '//ns:ItemIdentifierValue', $root );

        my $data = $self->ils->renew( $itemid, $userid );
        
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare(
            "SELECT * FROM items WHERE barcode = ?
                ");

        $sth->execute($itemid);
        my $data_br = $sth->fetchrow_hashref;
        

        if ( $data->{success} ) {
            my @elements = $root->findnodes('RenewItem/ItemElementType/Value');
            return $self->render_output(
                'response.tt',
                {
                    message_type => 'RenewItemResponse',
                    barcode      => $itemid,
                    userid       => $userid,
                    elements     => \@elements,
                    data         => $data,
                    branch       => $data_br->{'homebranch'},
                }
            );
        }
        else {
            return $self->render_output(
                'problem.tt',
                {
                    message_type => 'RenewItemResponse',
                    problems     => $data->{problems},
                }
            );
        }
    }
}

1;
