#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

our %INX = ('ML25997a'  => 'INXB',
            'ML25999a'  => 'INXD',);

our @IDS = qw(ML25993a ML25997a ML25998a ML25999a ML32831a ML218922a ML07312a ML223536a ML078817a ML47742a ML036514a ML129317a);

our $DIR = '../03-DATA/01-RSEM';

our @FILES = qw(B2.genes.results B3a.genes.results B3b.genes.results C2.genes.results C3.genes.results C6.genes.results S1.genes.results S2.genes.results S3.genes.results);

MAIN: {
    my $rh_d = get_data(\@FILES,$DIR,\%INX);
    my $rh_a = adjust_matrix($rh_d,\%INX);
    my $csv  = "INXB_tb,INXB_cr,INXB_st,INXD_tb,INXD_cr,INXD_st\n";
    for (my $i=0; $i < 3; $i++) {
        $csv .= "$rh_a->{'INXB'}->{'tb'}->[$i],";
        $csv .= "$rh_a->{'INXB'}->{'cr'}->[$i],";
        $csv .= "$rh_a->{'INXB'}->{'st'}->[$i],";
        $csv .= "$rh_a->{'INXD'}->{'tb'}->[$i],";
        $csv .= "$rh_a->{'INXD'}->{'cr'}->[$i],";
        $csv .= "$rh_a->{'INXD'}->{'st'}->[$i]\n";
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
