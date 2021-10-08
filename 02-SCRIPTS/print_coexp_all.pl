#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Storable;

our $VERSION = 0.01;

our $DIR = '/bwdata1/jfryan/72-MNEMIOPSIS/09-SEBE_RERUN/UMI_tables/Mnemiopsis';
our $UMI_STOR = 'mnemiopsis_single_cell_umi_hash.storable';
#our @INNEXINS = qw(ML25993a ML07312a ML223536a ML25998a ML218922a ML25999a ML32831a ML47742a ML078817a ML129317a ML25997a ML036514a);
our @INNEXINS = qw(ML25993a ML25997a ML25998a ML25999a ML32831a ML47742a ML218922a ML129317a ML07312a ML223536a ML036514a ML078817a ML13055a ML12047a ML215412a);
our %NAMES = ('ML25993a'  => 'INXA',
              'ML25997a'  => 'INXB',
              'ML25998a'  => 'INXC',
              'ML25999a'  => 'INXD',
              'ML32831a'  => 'INXG.1',
              'ML47742a'  => 'INXG.2',
              'ML218922a' => 'INXH',
              'ML129317a' => 'INXJ',
              'ML07312a'  => 'INXL',
              'ML223536a' => 'INXM',
              'ML036514a' => 'INXO',
              'ML078817a' => 'INXP',
              'ML13055a' => 'MleiOpsin1',
              'ML12047a' => 'MleiOpsin2',
              'ML215412a' => 'MleiOpsin3' );

MAIN: {
#    my $ra_files = get_files($DIR);
#    my $rh_data  = get_data($DIR,$ra_files);
#    Storable::store $rh_data, $UMI_STOR;
    my $rh_data = Storable::retrieve($UMI_STOR);
my $count = scalar(@{$rh_data->{'ML25999a'}});
    my $rh_counts = get_counts(\@INNEXINS,$rh_data);
#print "ML25997a: $rh_counts->{'ML25997a'}\n";
#print "ML25999a: $rh_counts->{'ML25999a'}\n";
#print "TOTAL: $count\n";
#exit;
    my $head = '#,';
    foreach my $id (@INNEXINS) {
        $head .= "$NAMES{$id}($rh_counts->{$id}),";
    }
#    foreach my $id (reverse(@INNEXINS)) {
#        $head .= "$id($rh_counts->{$id}),";
#    }
    chop $head;
    print "$head\n";
    my %seen = ();
    foreach my $mlid1 (@INNEXINS) {
        die "$mlid1 is not data\n" unless ($rh_data->{$mlid1});
        my $row = "$NAMES{$mlid1}($rh_counts->{$mlid1}),";
        foreach my $mlid2 (@INNEXINS) {
            die "$mlid2 is not data\n" unless ($rh_data->{$mlid2});
            if ($seen{$mlid2}->{$mlid1} || $mlid1 eq $mlid2) {
                $row .= ',';
            } else {
                my ($co_count,$coexp) = get_coexp($mlid1,$mlid2,$rh_data);
                $row .= "$co_count($coexp),";
                $seen{$mlid1}->{$mlid2}++;
            }
        }
        chop $row;
        print "$row\n";
    }
}

sub get_counts {
    my $ra_ids = shift;
    my $rh_d   = shift;
    my %counts = ();
    my %w_one  = ();
    foreach my $id (@{$ra_ids}) {
        $counts{$id} = get_indices_w_1($rh_d->{$id},\%w_one);
    }
    return (\%counts);
}

sub get_coexp {
    my $mlid1 = shift;
    my $mlid2 = shift;
    my $rh_d  = shift;
    my %cell_counts = ();
    my $mlid1_count = get_indices_w_1($rh_d->{$mlid1},\%cell_counts);
    my $mlid2_count = get_indices_w_1($rh_d->{$mlid2},\%cell_counts);
    my $co_count = 0;
    foreach my $index (keys %cell_counts) {
        $co_count++ if ($cell_counts{$index} == 2);
    }
    my $coexp = '';
    if ($mlid1_count >= $mlid2_count) {
        my $float = $co_count / $mlid2_count;
        $coexp = sprintf "%.3f", $float;
    } elsif ($mlid2_count > $mlid1_count) {
        my $float = $co_count / $mlid1_count;
        $coexp = sprintf "%.3f", $float;
    } elsif (($mlid1_count == 0) || ($mlid2_count == 0)) {
        $coexp = 0;
    } else {
        die "unexpected: $mlid1 \$mlid1_count($mlid1_count) = $mlid2 \$mlid2_count($mlid2_count)\n";
    }
    return ($co_count, $coexp);
}

sub get_indices_w_1 {
    my $ra_d = shift;
    my $rh_i = shift;
    my @indices = ();
    my $count = 0;
    for (my $i = 0; $i < @{$ra_d}; $i++) {
        $rh_i->{$i}++ if ($ra_d->[$i]);
        $count++ if ($ra_d->[$i]);
    }
    return $count;
}

sub get_data {
    my $dir  = shift;
    my $ra_f = shift;
    my %data = ();
    foreach my $file (@{$ra_f}) {
        open IN, "$dir/$file" or die "cannot open $dir/$file:$!";
        while (my $line = <IN>) {
            next unless ($line =~ m/^ML/);
            chomp $line;
            my @fields = split /\s+/, $line;
            my $id = shift @fields;
            push @{$data{$id}}, @fields;
        }
    }
    return \%data;
}

sub get_files {
    my $dir = shift;
    opendir DIR, $dir or die "cannot opendir $dir";
    my @files = grep {/.txt$/} readdir(DIR);
    return \@files;
}
