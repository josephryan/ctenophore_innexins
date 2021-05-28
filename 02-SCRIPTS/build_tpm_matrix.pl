#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

our @IDS = qw(ML25993a ML25998a ML32831a ML218922a ML07312a ML223536a ML078817a ML47742a ML036514a ML129317a);
our %INX = ('ML25993a'  => 'INXA',
            'ML25998a'  => 'INXC',
            'ML32831a'  => 'INXG.1',
            'ML218922a' => 'INXH',
            'ML07312a'  => 'INXL',
            'ML223536a' => 'INXM',
            'ML078817a' => 'INXP',
            'ML47742a'  => 'INXG.2',
            'ML036514a' => 'INXO',
            'ML129317a' => 'INXJ');

our $DIR = '../03-DATA/01-RSEM';

our @FILES = qw(B2.genes.results B3a.genes.results B3b.genes.results C2.genes.results C3.genes.results C6.genes.results S1.genes.results S2.genes.results S3.genes.results);

#our $TISSUE = 'tb';
#our $TISSUE = 'cr';
#our $TISSUE = 'st';

MAIN: {
    my $tissue = $ARGV[0] or die "usage: $0 TISSUE (tb, cr, or st)\n";
    my $rh_d = get_data(\@FILES,$DIR,\%INX);
    my $rh_a = adjust_matrix($rh_d,\%INX);
    my $csv  = '';
    foreach my $id (sort {$INX{$a} cmp $INX{$b} } (keys(%{$rh_d}))) {
        $csv .= "$INX{$id},";
    }
    chop $csv;
    $csv .= "\n";
    for (my $i=0; $i < 3; $i++) {
        foreach my $id (sort(keys(%{$rh_a}))) {
            $csv .= "$rh_a->{$id}->{$tissue}->[$i],";
        }
        chop $csv;
        $csv .= "\n";
    }
    print "$csv\n";
}

sub adjust_matrix {
    my $rh_d = shift;
    my $rh_inx = shift;
    my %mat  = ();
    foreach my $id (keys %{$rh_d}) {
        $mat{$rh_inx->{$id}}->{'tb'} = [$rh_d->{$id}->{'B2.genes.results'},$rh_d->{$id}->{'B3a.genes.results'},$rh_d->{$id}->{'B3b.genes.results'}];
        $mat{$rh_inx->{$id}}->{'cr'} = [$rh_d->{$id}->{'C2.genes.results'},$rh_d->{$id}->{'C3.genes.results'},$rh_d->{$id}->{'C6.genes.results'}];
        $mat{$rh_inx->{$id}}->{'st'} = [$rh_d->{$id}->{'S1.genes.results'},$rh_d->{$id}->{'S2.genes.results'},$rh_d->{$id}->{'S3.genes.results'}];
    }
    return \%mat;
}

sub get_data {
    my $ra_f = shift;
    my $dir  = shift;
    my $rh_i = shift;
    my %data = ();
    foreach my $file (@{$ra_f}) {
        open IN, "$dir/$file" or die "cannot open $dir/$file:$!";
        while (my $line = <IN>) {
            $line =~ m/^(\S+)\s+\S+\s+(.*)/ or die "unexpected: $line"; 
            my $inx = $1;
            my $dat = $2;
            next unless $rh_i->{$inx};
            my @fields = split /\s+/, $dat;
            $data{$inx}->{$file} = $fields[3];
        }
    }
    return \%data;
}
