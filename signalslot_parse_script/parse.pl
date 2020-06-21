#!/usr/bin/perl
use strict;
use warnings;

#print "$ARGV[0]+$ARGV[1] is ",$ARGV[0]+$ARGV[1],"\n";
my $defaultfile = $ARGV[0];
my $mainfile = $ARGV[1];

open( my $default_fh, "<", $defaultfile ) or die $!;
open( my $main_fh,    ">", $mainfile )    or die $!;

#my $signal_exist;
# my @signal_func;
# push(@signal_func, $func);
while ( my $line = <$default_fh> ) {
    if($line =~ /signal/){
        my $flag = 0;
        my @line_arr = split(/(\;)/,$line);
        foreach (@line_arr){
            my $line_arr_ele = $_;
            if($line_arr_ele =~ /signal/){
                $flag = 1;
                my ($func) = $line_arr_ele =~ /signal(.+)\(/;
                $func =~ s/^\s+|\s+$//g;
                my ($arg_arr) = $line_arr_ele =~ /\((.+)\)/;
                my @arg = split /\s/, $arg_arr;
                my $message = <<"END_MESSAGE";
	$arg[0] public $func\_$arg[1];
	bytes public $func\_$arg[1]slot;
	uint public $func\_sigId;
	
    function $func\() public{
		assembly {
			sstore($func\_sigId\_slot,createsig(sload($func\_$arg[1]_slot)))
			mstore($func\_$arg[1]slot_slot,$func\_$arg[1]_slot)
		}
    }
END_MESSAGE
                print {$main_fh} $message;
            }else{
                if($flag == 1){
                    $flag = 0;
                }else{
                    print {$main_fh} $line_arr_ele;
                }
            }
        }
    }elsif($line =~ /\.bind\(/){
        my $flag = 0;
        my @line_arr = split(/(\;)/,$line);
        foreach (@line_arr){
            my $line_arr_ele = $_;
            if($line_arr_ele =~ /\.bind\(/){
                $flag = 1;
                $line_arr_ele = "$line_arr_ele\;";
                my ($slot_obj) = $line_arr_ele =~ /(\w+)\.bind/;
                my ($sig_obj) = $line_arr_ele =~ /\.bind\((.+)\)\;/;
                if($sig_obj =~ /\./){}else{$sig_obj = "this\.$sig_obj";}
                my ($sig_obj_func) = "$sig_obj\)" =~ /\.(\w+)\)/;
                print "$sig_obj_func";
                my ($emiter) = $sig_obj =~ /(.+)\.$sig_obj_func/;
                print "$emiter";
                my $message = <<"END_MESSAGE";
		address $emiter\_address = address($emiter\);
		uint $emiter\_$sig_obj_func\_sigId = $emiter\.$sig_obj_func\_sigId\();
		assembly {
			bindsig($emiter\_address,$emiter\_$sig_obj_func\_sigId,3,4,5)
	    }
END_MESSAGE
                print {$main_fh} $message;
            }else{
                if($flag == 1){
                    $flag = 0;
                }else{
                    print {$main_fh} $line_arr_ele;
                }
            }
        }
    }else{
        print {$main_fh} $line;
    }
}
close $default_fh;
close $main_fh;
