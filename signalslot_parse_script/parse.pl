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
	$arg[0] public $func\_data;
	bytes public $func\_dataslot;
	uint public $func\_sigId;
    bytes4 public $func\_key;
	
    function $func\() public{
        $func\_key = keccak256(\"function $func\(\)\")\[0\];
		assembly {
			sstore($func\_sigId\_slot,createsig(extcodesize($func\_data_slot),sload($func\_key_slot)))
			mstore($func\_dataslot_slot,$func\_data_slot)
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
                my $emiter_tr = $emiter;
                $emiter_tr =~ tr/\./\_/;
                my $message = <<"END_MESSAGE";
		address $emiter_tr\_address = address($emiter\);
		uint $emiter_tr\_$sig_obj_func\_sigId = $emiter\.$sig_obj_func\_sigId\();
		assembly {
			bindsig($emiter_tr\_address,$emiter_tr\_$sig_obj_func\_sigId,sload($slot_obj\_slotId_slot))
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
    bytes4 public $slot_name\_codePtr;
    function $slot_name\() public{
        $slot_name\_codePtr = keccak256(\"$slot_title\")\[0\];
        assembly {
            sstore($slot_name\_slotId_slot,createslot(8,sload($slot_name\_codePtr_slot),1,2))
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
    }elsif($line =~ /emitsig\s/){
        my $flag = 0;
        my @line_arr = split(/(\;)/,$line);
        foreach (@line_arr){
            my $line_arr_ele = $_;
            if($line_arr_ele =~ /emitsig\s/){
                $flag = 1;
                $line_arr_ele = "$line_arr_ele\;";
                my ($signal_type) = $line_arr_ele =~ /^(.*?)\(/s;
                my @arg = split /\s+/, $signal_type;
                if($arg[0] eq "emitsig"){
                    $signal_type = $arg[1];
                }else{
                    $signal_type = $arg[2];
                }  
                my ($sig_obj_func) = "$signal_type\;" =~ /\.(\w+)\;/;
                my ($emiter) = $signal_type =~ /(.+)\.$sig_obj_func/;
                my ($delay_obj) = $line_arr_ele =~ /\.delay\((.+)\)\;/;
                my ($emit_obj) = $line_arr_ele =~ /\((.+)\)\.delay\(/;
                my $emiter_tr = $emiter;
                $emiter_tr =~ tr/\./\_/;
                my $message = <<"END_MESSAGE";
		bytes memory $emiter_tr\_$sig_obj_func\_dataslot = $emiter\.$sig_obj_func\_dataslot();
		uint $emiter_tr\_$sig_obj_func\_sigId = $emiter\.$sig_obj_func\_sigId();
		assembly {
			mstore($emiter_tr\_$sig_obj_func\_dataslot,mload($emit_obj\_slot))
			emitsig($emiter_tr\_$sig_obj_func\_sigId,$delay_obj,$emiter_tr\_$sig_obj_func\_dataslot,1)
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
    }elsif($line =~ /\.detach\(/){
        my $flag = 0;
        my @line_arr = split(/(\;)/,$line);
        foreach (@line_arr){
            my $line_arr_ele = $_;
            if($line_arr_ele =~ /\.detach\(/){
                $flag = 1;
                $line_arr_ele = "$line_arr_ele\;";
                my ($slot_obj) = $line_arr_ele =~ /(\w+)\.detach/;
                my ($sig_obj) = $line_arr_ele =~ /\.detach\((.+)\)\;/;
                if($sig_obj =~ /\./){}else{$sig_obj = "this\.$sig_obj";}
                my ($sig_obj_func) = "$sig_obj\)" =~ /\.(\w+)\)/;
                my ($emiter) = $sig_obj =~ /(.+)\.$sig_obj_func/;
                my $emiter_tr = $emiter;
                $emiter_tr =~ tr/\./\_/;
                my $message = <<"END_MESSAGE";
		uint $emiter_tr\_$sig_obj_func\_sigId = $emiter\.$sig_obj_func\_sigId();
		address $emiter_tr\_address = address($emiter\);
		assembly{
			detachsig($emiter_tr\_address,$emiter_tr\_$sig_obj_func\_sigId,sload($slot_obj\_slotId_slot))
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
