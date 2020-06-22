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
    if($line =~ /signal\s/){
        my $flag = 0;
        my @line_arr = split(/(\;)/,$line);
        foreach (@line_arr){
            my $line_arr_ele = $_;
            if($line_arr_ele =~ /signal\s/){
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
			sstore($func\_sigId\_slot,createsig(extcodesize($func\_$arg[1]_slot)))
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
                my ($emiter) = $sig_obj =~ /(.+)\.$sig_obj_func/;
                my $message = <<"END_MESSAGE";
		address $emiter\_address = address($emiter\);
		uint $emiter\_$sig_obj_func\_sigId = $emiter\.$sig_obj_func\_sigId\();
		assembly {
			bindsig($emiter\_address,$emiter\_$sig_obj_func\_sigId,ssload($slot_obj\_slotId_slot))
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
    }elsif($line =~ /slot\s/){ #ignore xxx;slot {}xxxx
        my $slot_end_counter = 0;
        $slot_end_counter = $slot_end_counter + ($line =~ /\{/g) - ($line =~ /\}/g);
        my ($slot_name) = $line =~ /([\w,\_]+)\(/;
        my ($slot_obj) = $line =~ /\((.+)\)/;
        my ($slot_title) = $line =~ /$slot_name(.+)\)/;
        $slot_title = "$slot_name\_func$slot_title\)";
        my @arg = split /\s/, $slot_obj;#argment format must be "blalba[] blabla"
        my $message = <<"END_MESSAGE";
    uint public $slot_name\_slotId;
    function $slot_name\() public{
        bytes4 codePtr = keccak256(\"$slot_title\")\[0\];
        assembly {
            sstore($slot_name\_slotId_slot,createslot(8,codePtr,1,2))
        }		
    }
    function $slot_title public{
END_MESSAGE
        print {$main_fh} $message;
        while ($slot_end_counter != 0){
            $line = <$default_fh>;
            $slot_end_counter = $slot_end_counter + ($line =~ /\{/g) - ($line =~ /\}/g);
            print {$main_fh} $line;
        }
    }else{
        print {$main_fh} $line;
    }
}
close $default_fh;
close $main_fh;
