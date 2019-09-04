package NCIP::Handler::LookupUser;

=head1

  NCIP::Handler::LookupUser

=head1 SYNOPSIS

    Not to be called directly, NCIP::Handler will pick the appropriate Handler 
    object, given a message type

=head1 FUNCTIONS

=cut

use Modern::Perl;

use NCIP::Handler;
use NCIP::User;

our @ISA = qw(NCIP::Handler);

sub handle {
    my $self   = shift;
    my $xmldoc = shift;

    my $config = $self->{config}->{koha};

    if ($xmldoc) {

        # Given our xml document, lets find our userid
        my ($user_id) =
          $xmldoc->getElementsByTagNameNS( $self->namespace(),
            'UserIdentifierValue' );

        my $xpc = $self->xpc();

        my $pin;
        unless ($user_id) {

            # We may get a password, username combo instead of userid
            # Need to deal with that also
            my $root = $xmldoc->documentElement();
            my @authtypes =
              $xpc->findnodes( '//ns:AuthenticationInput', $root );

            my $barcode;

            foreach my $node (@authtypes) {
                my $class =
                  $xpc->findnodes( './ns:AuthenticationInputType', $node );

                my $value =
                  $xpc->findnodes( './ns:AuthenticationInputData', $node );

                if ( $class->[0]->textContent eq 'Barcode Id' ) {
                    $barcode = $value->[0]->textContent;
                }
                elsif ( $class->[0]->textContent eq 'PIN' ) {
                    $pin = $value->[0]->textContent;
                }

            }

            $user_id = $barcode;
        }
        else {
            $user_id = $user_id->textContent();
        }

        # We may get a password, username combo instead of userid
        # Need to deal with that also

        my $user = NCIP::User->new( { userid => $user_id, ils => $self->ils } );
        $user->initialise();

        if ($pin) {
            if ( $user->is_valid() ) {
                my $authenticated = $user->authenticate( { pin => $pin } );

                unless ($authenticated) {    # User is valid, password is not
                    return $self->render_output(
                        'problem.tt',
                        {
                            message_type => 'LookupUserResponse',
                            problems     => [
                                {
                                    problem_type =>
                                      'User Authentication Failed',
                                    problem_detail =>
                                      'Barcode Id or Password are invalid',
                                    problem_element => 'Password',
                                    problem_value   => $pin,
                                }
                            ]
                        }
                    );
                }
            }
            else {    # User is invalid
                return $self->render_output(
                    'problem.tt',
                    {
                        message_type => 'LookupUserResponse',
                        problems     => [
                            {
                                problem_type => 'User Authentication Failed',
                                problem_detail =>
                                  'Barcode Id or Password are invalid',
                                problem_element => 'Barcode Id',
                                problem_value   => $user_id,
                            }
                        ]
                    }
                );
            }
        }

        my $vars;

        #  this bit should be at a lower level
        my ( $from, $to ) = $self->get_agencies($xmldoc);

        # we switch these for the templates
        # because we are responding, to becomes from, from becomes to

        # if we have blank user, we need to return that
        # and can skip looking for elementtypes
        my $dbh = C4::Context->dbh;
        
        my $sth_iss = $dbh->prepare("select * from borrowers where cardnumber = ?");
        $sth_iss->execute($user_id);
        my $data_iss = $sth_iss->fetchrow_hashref;
        my $sth_issitems = $dbh->prepare("select  i.barcode as barcode
                          , b.title as title
                          , b.author as author
                          , t.description as itype
                          , iss.issuedate as IssuedDate
                          , date(iss.date_due) as date_due
                          , 0 as Recalled
                          , case (iss.date_due < CURRENT_DATE()) 
                          when true 
                          then ifnull((SELECT amountoutstanding FROM accountlines al where al.borrowernumber = bo.borrowernumber and al.issue_id = iss.issue_id   order by STR_TO_DATE(SUBSTRING(al.description from LENGTH(al.description) - 16),'%d/%m/%Y %H:%i') desc limit 1), 0)
                            else 0 end as amountoutstanding
                          , '' as ReminderLevel
                          from issues iss
                             inner join borrowers bo on iss.borrowernumber = bo.borrowernumber
                             inner join items i on iss.itemnumber = i.itemnumber
                             inner join biblioitems bi on i.biblioitemnumber = bi.biblioitemnumber
                             inner join biblio b on bi.biblionumber = b.biblionumber
                             inner join itemtypes t on t.itemtype = i.itype
                         where bo.cardnumber = ?");
        $sth_issitems->execute($user_id);
        my @value;
        while (my $data_issitems = $sth_issitems->fetchrow_hashref) {
            my $itemnumber = $data_issitems->{'itemnumber'};          
            push @value, $data_issitems;
        }  
        
        my $sth_issitems_r = $dbh->prepare("select distinct biblio.biblionumber, biblio.title as title, reserves.reservedate as reservedate, reserves.expirationdate as expirationdate, items.itype as itype, items.barcode as barcode, items.homebranch as homebranch from reserves left join biblio on biblio.biblionumber = reserves.biblionumber left join items on items.biblionumber = reserves.itemnumber where reserves.borrowernumber = ?");
        $sth_issitems_r->execute($data_iss->{'borrowernumber'});        
        my @value_r;
        while (my $data_issitems_r = $sth_issitems_r->fetchrow_hashref) {
            my $itemnumberr = $data_issitems_r->{'itemnumber'};          
            push @value_r, $data_issitems_r;
        }  
        
        
        my $sth_issitems_r1 = $dbh->prepare("select biblio.title as title, reserves.reservedate as reservedate, reserves.expirationdate as expirationdate, items.itype as itype, reserves.itemnumber, items.barcode as barcode, items.homebranch as homebranch from reserves left join biblio on biblio.biblionumber = reserves.biblionumber left join items on items.biblionumber = reserves.itemnumber where reserves.borrowernumber = ?");
        $sth_issitems_r1->execute($data_iss->{'borrowernumber'});        
        my @value_r1;
        while (my $data_issitems_r1 = $sth_issitems_r1->fetchrow_hashref) {
            my $itemnumberr1 = $data_issitems_r1->{'itemnumber'};          
            push @value_r1, $data_issitems_r1;
        } 
        
    
        if ( $user->is_valid() ) {
            my $elements = $self->get_user_elements($xmldoc);
            return $self->render_output(
                'response.tt',
                {
                    message_type => 'LookupUserResponse',
                    from_agency  => $to,
                    to_agency    => $from,
                    elements     => $elements,
                    user         => $user,
                    loans        => \@value,
                    resrs        => \@value_r,
                    #resrsits      => \@value_r1,
                    user_id      => $user_id,
                    config       => $config,
                }
            );
        }
        else {
            return $self->render_output(
                'problem.tt',
                {
                    message_type => 'LookupUserResponse',
                    problems     => [
                        {
                            problem_type    => 'Unkown User',
                            problem_detail  => 'User is not known',
                            problem_element => 'UserId',
                            problem_value   => $user_id,
                        }
                    ]
                }
            );
        }
    }
}

1;
