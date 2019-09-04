package NCIP::Dancing;

use Dancer ':syntax';
use FindBin;
use Cwd qw/realpath/;
use XML::Tidy::Tiny qw(xml_tidy);
use Log::Log4perl;

use NCIP;

our $VERSION = '0.1';

any [ 'get', 'post' ] => '/' => sub {
    my $appdir = realpath("$FindBin::Bin/..");

    #FIXME: Why are we always looking in t for the config, even for production?
    my $ncip = NCIP->new("$appdir/t/config_sample");
    my $log  = Log::Log4perl->get_logger("NCIP");

    $log->debug("MESSAGE INCOMING");
    $log->debug("INCOMING PARAMS: ") . Data::Dumper::Dumper scalar params;

    my $xml = param 'xml';
    $xml ||= param 'XForms:Model';
    if ( !$xml && request->is_post ) {
        $xml = request->body;
    }

    $log->debug("RAW XML: **$xml**");
    $log->debug("FORMATTED XML: \n" . xml_tidy( $xml ) );

    my $content = $ncip->process_request( $xml, config );

    $log->debug("NCIP::Dancing: Finished processing request");
    $log->debug("NCIP::Dancing: About to generate XML response");

    my $xml_response = template 'main',
      { content => $content, ncip_version => $ncip->{ncip_protocol_version} };
    $xml_response = xml_tidy($xml_response);

    $log->debug("XML RESPONSE: \n$xml_response");

    return $xml_response;
};

true;
