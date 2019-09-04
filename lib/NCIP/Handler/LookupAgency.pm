package NCIP::Handler::LookupAgency;

=head1

  NCIP::Handler::LookupAgency

=head1 SYNOPSIS

    Not to be called directly, NCIP::Handler will pick the appropriate Handler 
    object, given a message type

=head1 FUNCTIONS

=cut

use Modern::Perl;

use NCIP::Handler;
use NCIP::Response;
use C4::Auth qw{
  checkpw_hash
};

our @ISA = qw(NCIP::Handler);

sub handle {
    my $self   = shift;
    my $xmldoc = shift;
    if ($xmldoc) {
        my ( $from, $to ) = $self->get_agencies($xmldoc);
        
        $from = trim($from);
        $to = trim($to);
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare(
            "SELECT * FROM branches WHERE branchcode = ?
                ");

        $sth->execute($from);
        my $data = $sth->fetchrow_hashref;         
    
        if (($data->{'branchcode'}) eq ($to)) {
            return $self->render_output(
                'response.tt',
                {
                    from_agency  => $to,
                    to_agency    => $from,
                    branch       => $data->{'branchcode'},
                    branchname   => $data->{'branchname'},
                    message_type => 'LookupAgencyResponse',               

                }
            );
     
        } else {
            return $self->render_output(
                'problem.tt',
                {
                    message_type => 'LookupAgencyResponse',
                     problems     => [
                            {
                                problem_type => 'Branch not found',
                                
                            }
                        ]
                }
            );
        }   
    }
}

sub trim($)
{
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}

1;
