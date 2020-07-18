#!/usr/bin/perl
use strict;
use warnings;


my $defaultfile = $ARGV[0];
my $mainfile = $ARGV[1];

open( my $default_fh, "<", $defaultfile ) or die $!;
open( my $main_fh,    ">", $mainfile )    or die $!;


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
                my $message;
                if(defined $arg_arr){
                    my @arg = split /\s/, $arg_arr;
                    my $argc = 0;
                    if(($arg[0] eq "uint")|($arg[0] eq "int")){#now it can accept int/uint bytes1-32, byte[..],byte
                        $argc = 32;
                    }elsif($arg[0] eq "byte"){
                        $argc = 1;
                    }elsif($arg[0] =~ /byte/){
                        ($argc) = $arg[0] =~ /(\d+)/;
                    }
                    $message = <<"END_MESSAGE";
	$arg[0] public $func\_data;
	bytes public $func\_dataslot;
	uint public $func\_status;
    bytes32 public $func\_key;
	function set\_$func\_data\($arg[0] dataSet) public {
       $func\_data = dataSet;
    }
	function get\_$func\_argc\(\) public pure returns (uint argc){
       return $argc;
    }
	function get\_$func\_key\() public view returns (bytes32 key){
       return $func\_key;
    }
    function get\_$func\_dataslot\() public view returns (bytes memory dataslot){
       return $func\_dataslot;
    }
    function $func\() public{
        $func\_key = keccak256(\"function $func\(\)\");
		assembly {
			sstore($func\_status\_slot,createsig($argc, sload($func\_key_slot)))
			sstore($func\_dataslot_slot,$func\_data_slot)
		}
    }
END_MESSAGE
                }else{#if there is no emit data defined
                    $message = <<"END_MESSAGE";
	bytes public $func\_dataslot;\/\/the data pointer is NULL
	uint public $func\_status;
    bytes32 public $func\_key;
	function get\_$func\_key\() public view returns (bytes32 key){
       return $func\_key;
    }
    function get\_$func\_dataslot\() public view returns (bytes memory dataslot){
       return $func\_dataslot;
    }
    function $func\() public{
        $func\_key = keccak256(\"function $func\(\)\");
		assembly {
			sstore($func\_status\_slot,createsig(0, sload($func\_key_slot)))
			sstore($func\_dataslot_slot,0x0)
		}
    }
END_MESSAGE
                }
                print {$main_fh} $message;
            }else{
                if($flag == 1){#the flag is used for avoid printing additional ";"
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
		bytes32 $emiter_tr\_$sig_obj_func\_key = $emiter\.get\_$sig_obj_func\_key\();
		assembly {
			mstore(0x40,bindsig($emiter_tr\_address,$emiter_tr\_$sig_obj_func\_key,sload($slot_obj\_key_slot)))
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
        my $argc = 0;
        my @arg;
        my $hash_slot_title;
        if(defined $slot_obj){
            @arg = split /\s/, $slot_obj;#argment format must be "blalba[] blabla"
            if(($arg[0] eq "uint")|($arg[0] eq "int")){#now it can accept int/uint bytes1-32, byte[..],byte
                $argc = 32;
            }elsif($arg[0] eq "byte"){
                $argc = 1;
            }elsif($arg[0] =~ /byte/){
                ($argc) = $arg[0] =~ /(\d+)/;
            }
            $hash_slot_title = "$slot_name\_func\($arg[0]\)";
        }else{
            $hash_slot_title = "$slot_name\_func\(\)";
        }
        my $message = <<"END_MESSAGE";
    uint public $slot_name\_status;
    bytes32 public $slot_name\_key;
    function $slot_name\() public{
        $slot_name\_key = keccak256(\"$hash_slot_title");
        assembly {
            sstore($slot_name\_status_slot,createslot($argc,10,30000,sload($slot_name\_key_slot)))
        }		
    }
    function $slot_title public{
END_MESSAGE
        print {$main_fh} $message;
        while ($slot_end_counter != 0){
            $line = <$default_fh>;
            $slot_end_counter = $slot_end_counter + ($line =~ /\{/g) - ($line =~ /\}/g);
            # if($slot_end_counter == 0){
            #     print {$main_fh} "\}\n";
            # }
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
                if ($signal_type =~ /\./){
                    #do nothing
                }else{
                    $signal_type = "this.$signal_type";
                }
                my ($sig_obj_func) = "$signal_type\;" =~ /\.(\w+)\;/;
                my ($emiter) = $signal_type =~ /(.+)\.$sig_obj_func/;
                my ($delay_obj) = $line_arr_ele =~ /\.delay\((.+)\)\;/;
                my ($emit_obj) = $line_arr_ele =~ /\((.+)\)\.delay\(/;
                my $emiter_tr = $emiter;
                $emiter_tr =~ tr/\./\_/;
                my $message;
                if(defined $emit_obj){
                $message = <<"END_MESSAGE";
        $emiter\.set_$sig_obj_func\_data\($emit_obj\);
        uint $emiter_tr\_$sig_obj_func\_argc = $emiter\.get\_$sig_obj_func\_argc();
		bytes memory $emiter_tr\_$sig_obj_func\_dataslot = $emiter\.get\_$sig_obj_func\_dataslot();
		bytes32 $emiter_tr\_$sig_obj_func\_key = $emiter\.get\_$sig_obj_func\_key();
		assembly {
			mstore(0x40,emitsig($emiter_tr\_$sig_obj_func\_key,$delay_obj,$emiter_tr\_$sig_obj_func\_dataslot,$emiter_tr\_$sig_obj_func\_argc))
	    }
END_MESSAGE
                }else{#if no data emitted defined
                $message = <<"END_MESSAGE";
		bytes memory $emiter_tr\_$sig_obj_func\_dataslot = $emiter\.get\_$sig_obj_func\_dataslot();
		bytes32 $emiter_tr\_$sig_obj_func\_key = $emiter\.get\_$sig_obj_func\_key();
		assembly {
			mstore(0x40,emitsig($emiter_tr\_$sig_obj_func\_key,$delay_obj,$emiter_tr\_$sig_obj_func\_dataslot,0))
	    }
END_MESSAGE
                }
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
		bytes32 $emiter_tr\_$sig_obj_func\_key = $emiter\.get\_$sig_obj_func\_key();
		address $emiter_tr\_address = address($emiter\);
		assembly{
			mstore(0x40,detachsig($emiter_tr\_address,$emiter_tr\_$sig_obj_func\_key,sload($slot_obj\_key_slot)))
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
