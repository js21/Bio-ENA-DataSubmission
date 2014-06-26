#!/usr/bin/env perl
BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
	use Test::Output;
	use Test::Exception;
}

use Moose;
use File::Temp;
use Bio::ENA::DataSubmission::Spreadsheet;
use File::Slurp;
use File::Path qw( remove_tree);

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();


use_ok('Bio::ENA::DataSubmission::CommandLine::GenerateManifest');

my ( @args, $obj, @exp_ers );

#----------------------#
# test illegal options #
#----------------------#

@args = ();
$obj = Bio::ENA::DataSubmission::CommandLine::GenerateManifest->new( args => \@args );
throws_ok {$obj->run} 'Bio::ENA::DataSubmission::Exception::InvalidInput', 'dies without arguments';

@args = ('-t');
$obj = Bio::ENA::DataSubmission::CommandLine::GenerateManifest->new( args => \@args );
throws_ok {$obj->run} 'Bio::ENA::DataSubmission::Exception::InvalidInput', 'dies with invalid arguments';

@args = ('-t', 'rex');
$obj = Bio::ENA::DataSubmission::CommandLine::GenerateManifest->new( args => \@args );
throws_ok {$obj->run} 'Bio::ENA::DataSubmission::Exception::InvalidInput', 'dies with invalid arguments';

@args = ('-i');
$obj = Bio::ENA::DataSubmission::CommandLine::GenerateManifest->new( args => \@args );
throws_ok {$obj->run} 'Bio::ENA::DataSubmission::Exception::InvalidInput', 'dies with invalid arguments';

@args = ('-i', 'pod');
$obj = Bio::ENA::DataSubmission::CommandLine::GenerateManifest->new( args => \@args );
throws_ok {$obj->run} 'Bio::ENA::DataSubmission::Exception::InvalidInput', 'dies with invalid arguments';

@args = ('-t', 'rex', '-i', '10665_2#81');
$obj = Bio::ENA::DataSubmission::CommandLine::GenerateManifest->new( args => \@args );
throws_ok {$obj->run} 'Bio::ENA::DataSubmission::Exception::InvalidInput', 'dies with invalid arguments';

@args = ('-t', 'file', '-i', 'not/a/file');
$obj = Bio::ENA::DataSubmission::CommandLine::GenerateManifest->new( args => \@args );
throws_ok {$obj->run} 'Bio::ENA::DataSubmission::Exception::FileDoesNotExist', 'dies with invalid arguments';

@args = ('-t', 'lane', '-i', '10665_2#81', '-o', 'not/a/file');
$obj = Bio::ENA::DataSubmission::CommandLine::GenerateManifest->new( args => \@args );
throws_ok {$obj->run} 'Bio::ENA::DataSubmission::Exception::CannotWriteFile', 'dies with invalid arguments';


#--------------#
# test methods #
#--------------#

# check correct ERS numbers, sample names, supplier names

# lane
@exp_ers = ( ['ERS311393', '2047STDY5552104', 'RVI551'] );
@args = ( '-t', 'lane', '-i', '10665_2#81', '-o', "$tmp/manifest.xls" );
$obj = Bio::ENA::DataSubmission::CommandLine::GenerateManifest->new( args => \@args );
ok( $obj->run );
is $obj->sample_data, \@exp_ers, 'Correct lane ERS';

# file
@exp_ers = ( ['ERS311560', '2047STDY5552273', 'UNC718'], ['ERS311393', '2047STDY5552104', 'RVI551'], ['ERS311489', '2047STDY5552201', 'UNC647']);
@args = ( '-t', 'file', '-i', 't/data/lanes.txt', '-o', '' );
$obj = Bio::ENA::DataSubmission::CommandLine::GenerateManifest->new( args => \@args );
ok( $obj->run );
is $obj->sample_data, \@exp_ers, 'Correct file ERSs';


# check spreadsheet
@args = ( '-t', 'file', '-i', 't/data/lanes.txt' '-o', "$tmp/manifest.xls");
$obj = Bio::ENA::DataSubmission::CommandLine::GenerateManifest->new( args => \@args );

#my $exp_xls = Bio::ENA::DataSubmission::Spreadsheet->new( file => 't/data/exp_manifest.xls')->parse;
#my $got_xls = Bio::ENA::DataSubmission::Spreadsheet->new( file => "$tmp/manifest.xls")->parse;
#is_deeply $got_xls, $exp_xls, 'Spreadsheet is correct';
ok( $obj->run, 'Manifest generated' );
is(
	read_file('t/data/exp_manifest.xls'),
	read_file("$tmp/manifest.xls"),
	'Manifest file correct'
);

remove_tree($tmp);
done_testing();
