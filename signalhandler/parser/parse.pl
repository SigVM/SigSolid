#!/usr/bin/perl

# Signal Handler Smart Contract Parser
#
# Very rough implementation of the higher level solidity features neccessary to support signals and handlers.
# This script does one simple pass through an entire solidity file and replaces key methods with the assembly
# code that performs the task. It obviously is not a production grade compiler or anything of that sort, but
# it does act as a proof of concept.

use strict;
use warnings;

# Get file handles for input and output
my $input_file = $ARGV[0];
my $output_file = $ARGV[1];
my @signal_array = ();
my @handler_name_array = ();
my @handler_types_array = ();
open(my $read_fh,  "<", $input_file) or die $!;
open(my $write_fh, ">", "$output_file\.temp") or die $!;

while (my $line = <$read_fh>) {
    # Remove all comments from the input file.
    # TODO: Doesn't treat inline comments properly. Doesn't really matter though.
    if ($line =~ /\/\//){
        next;
    }

    #################################################################################
    #################################################################################
    # Signal declaration
    if ($line =~ /signal\s/) {
        # Get signal prototype from the name and remove spaces.
        my ($signal_prototype) = $line =~ /signal\s+(.+)\;/;
        $signal_prototype =~ s/\s+//g;
        # Get signal name.
        my ($signal_name) = $line =~ /signal\s+(.+)\(/;
        # Save signal name.
        push(@signal_array, ($signal_name));
        # Code snippet that represents the signal.
        my $code_snippet = 
<<"CODE_SNIPPET";
// Original code: signal ${signal_prototype};
bytes32 private ${signal_name}_key;
function set_${signal_name}_key() private {
    ${signal_name}_key = keccak256("${signal_prototype}");
}
////////////////////
CODE_SNIPPET
        print {$write_fh} $code_snippet;
        next;
    }

    #################################################################################
    #################################################################################
    # Create signal
    if ($line =~ /\.create_signal\(/) {
        my ($signal_name) = $line =~ /\s*(.+)\./;
        my $code_snippet = 
<<"CODE_SNIPPET";
// Original code: ${signal_name}.create_signal();
set_${signal_name}_key();
assembly {
    mstore(0x00, createsignal(sload(${signal_name}_key.slot)))
}
////////////////////
CODE_SNIPPET
        print {$write_fh} $code_snippet;
        next;
    }

    #################################################################################
    #################################################################################
     # Delete signal
    if ($line =~ /\.delete_signal\(/) {
        my ($signal_name) = $line =~ /\s+(.+)\./;
        my $code_snippet = 
<<"CODE_SNIPPET";
// Original code: ${signal_name}.delete_signal();
${signal_name}_key = 0;
assembly {
    mstore(0x00, deletesignal(sload(${signal_name}_key.slot)))
}
////////////////////
CODE_SNIPPET
        print {$write_fh} $code_snippet;
        next;
    }
    
    #################################################################################
    #################################################################################
    # Emit
    if ($line =~ /\.emit\(/) {
        my ($signal_name) = $line =~ /\s*(.+)\./;
        $signal_name =~ s/\.(.+)//g;
        my ($arg_string) = $line =~ /emit\((.+)\).target/;
        $arg_string =~ s/\s+//g;
        $arg_string =~ s/\)\.(.+)//g;
        my @arg_arr = split(',', $arg_string);
        my ($delay_value) = $line =~ /delay\((.+)\)/;
        my ($handler_array) = $line =~ /target\((.+)\).delay/;
        my $code_snippet_with_args = 
<<"CODE_SNIPPET";
// Original code: ${signal_name}.emit(${arg_string}).target($handler_array).delay($delay_value);
bytes memory abi_encoded_${signal_name}_data = abi.encode($arg_string);
// This length is measured in bytes and is always a multiple of 32.
uint abi_encoded_${signal_name}_length = abi_encoded_${signal_name}_data.length;
bytes memory abi_encoded_${signal_name}_handlers = abi.encode($handler_array);
uint abi_encoded_${signal_name}_handlers_length = abi_encoded_${signal_name}_handlers.length - 64;
assembly {
    mstore(
        0x00,
        sigemit(
            sload(${signal_name}_key.slot), 
            abi_encoded_${signal_name}_data,
            abi_encoded_${signal_name}_length,
            $delay_value,
            abi_encoded_${signal_name}_handlers,
            abi_encoded_${signal_name}_handlers_length
        )
    )
}
////////////////////
CODE_SNIPPET
        my $code_snippet_wo_args = 
<<"CODE_SNIPPET";
// Original code: ${signal_name}.emit().target($handler_array).delay($delay_value);
bytes memory abi_encoded_${signal_name}_handlers = abi.encode($handler_array);
uint abi_encoded_${signal_name}_handlers_length = abi_encoded_${signal_name}_handlers.length - 64;
assembly {
    mstore(
        0x00,
        sigemit(
            sload(${signal_name}_key.slot), 
            0,
            0,
            $delay_value,
            abi_encoded_${signal_name}_handlers,
            abi_encoded_${signal_name}_handlers_length
        )
    )
}
////////////////////
CODE_SNIPPET
        if ($arg_string eq "") {
            print {$write_fh} $code_snippet_wo_args;
        } else {
            print {$write_fh} $code_snippet_with_args;
        }
        next;
    }

    #################################################################################
    #################################################################################
    # Bind
    if ($line =~ /\.bind\(/) {
        # Get handler name.
        my ($handler_name) = $line =~ /\s*(.+)\.bind/;
        # delete line space
        $line =~ s/\s+//g;
        # Get handler parameters.
        my ($arg_string) = $line =~ /bind\((.+)\)/;
        my @arg_arr = split(',', $arg_string);
        my ($address_parameter) = $arg_arr[0];
        my ($signal_parameter) = $arg_arr[1];
        $signal_parameter = substr($signal_parameter, index($signal_parameter, ".")+1);
        for (my $i = 0; $i <= $#handler_name_array; $i = $i + 1){
            if($handler_name eq $handler_name_array[$i]){
                $signal_parameter = $signal_parameter."(".$handler_types_array[$i].")";
            }
        }
        my ($ratio_parameter) = $arg_arr[2];
        my ($ratio) = $ratio_parameter * 100 + 100;
        my ($method_prototype);
        for (my $i = 0; $i <= $#handler_name_array; $i = $i + 1){
            if($handler_name eq $handler_name_array[$i]){
                $method_prototype = $handler_name_array[$i]."(".$handler_types_array[$i].")";
            }
        }
        my ($blk) = $arg_arr[3];
        if ($blk =~ "true") {$blk = 1} else {$blk = 0}
        my ($sigRoles) = $arg_arr[4];
        my ($sigMethods) = $arg_arr[5];
        my $code_snippet = 
<<"CODE_SNIPPET";
// Original code: ${line}
set_${handler_name}_key();
bytes32 ${handler_name}_method_hash = keccak256("${method_prototype}");
bytes32 ${handler_name}_signal_prototype_hash = keccak256("${signal_parameter}");
bytes memory abi_encoded_${handler_name}_sigRoles = abi.encode($sigRoles);
uint abi_encoded_${handler_name}_sigRoles_length = abi_encoded_${handler_name}_sigRoles.length - 64;
bytes memory abi_encoded_${handler_name}_sigMethods = abi.encode($sigMethods);
uint abi_encoded_${handler_name}_sigMethods_length = abi_encoded_${handler_name}_sigMethods.length - 64;

assembly {
    mstore(
        0x00,
        sigbind(
            sload(${handler_name}_key.slot),
            ${handler_name}_method_hash, 
            10000000, 
            $ratio,
            ${address_parameter},
            ${handler_name}_signal_prototype_hash,
            $blk,
            abi_encoded_${handler_name}_sigRoles,
            abi_encoded_${handler_name}_sigRoles_length,
            abi_encoded_${handler_name}_sigMethods,
            abi_encoded_${handler_name}_sigMethods_length
        )
    )
}
////////////////////
CODE_SNIPPET
        print {$write_fh} $code_snippet;
        next;
    }

    #################################################################################
    #################################################################################
    # Detach
    if ($line =~ /\.detach\(/) {
        my $original_code = $line;
        $original_code =~ s/\s+//g;
        my ($handler_name) = $line =~ /\s*(.+)\.detach/;
        my ($signal_prototype) = "";
        my ($arg_string) = $line =~ /detach\((.+)\)/;
        $arg_string =~ s/\s+//g;
        $arg_string =~ s/"(.+)"//g;
        my @arg_arr = split(',', $arg_string);
        $signal_prototype = substr($arg_arr[1], index($arg_arr[1], ".")+1);
        for (my $i = 0; $i <= $#handler_name_array; $i = $i + 1){
            if($handler_name eq $handler_name_array[$i]){
                $signal_prototype = $signal_prototype."(".$handler_types_array[$i].")";
            }
        }
        my $code_snippet = 
<<"CODE_SNIPPET";
// Original code: ${original_code}
bytes32 ${handler_name}_signal_prototype_hash = keccak256("${signal_prototype}");
assembly {
    mstore(
        0x00,
        sigdetach(
            sload(${handler_name}_key.slot),
            $arg_arr[0],
            ${handler_name}_signal_prototype_hash
        )
    )
}
////////////////////
CODE_SNIPPET
        print {$write_fh} $code_snippet;
        next;
    }

    #################################################################################
    #################################################################################
    # Handler declaration
    if ($line =~ /handler/) {
        # Original code
        my ($original_code) = $line;
        # delete left space
        $original_code =~ s/^\s+//;
        # delete enter
        chomp($original_code);
        # Save original function.
        my ($handler_function) = $line =~ /function(.+)handler/;
        # Get handler name.
        my ($handler_name) = $handler_function =~ /(.+)\(/;
        $handler_name =~ s/\s+//g;
        # save name to the global array
        push(@handler_name_array, ($handler_name));
        # Get handler parameters.
        my ($handler_parameters) = $handler_function =~ /\((.+)\)/;
        # Split parameter
        my @handler_parameter_arr;
        if (defined $handler_parameters) {	
                @handler_parameter_arr = split(',', $handler_parameters);
        }
        # Final string types only
        my $final_parameters = "";
        for (my $i = 0; $i <= $#handler_parameter_arr; $i = $i + 1){
            # delete left space
            $handler_parameter_arr[$i] =~ s/^\s+//;
            # delete right space
            $handler_parameter_arr[$i] =~ s/\s+$//;
            # get the type
            my ($temp) = $handler_parameter_arr[$i] =~ /^(.*?)\s/;
            $handler_parameter_arr[$i] = $temp;
            # append types
            $final_parameters = $final_parameters." ".$handler_parameter_arr[$i];
        }
        # delete left space
        $final_parameters =~ s/^\s+//;
        # replace space with comma
        $final_parameters =~ s/ /,/g;
        # save types to the global array
        push(@handler_types_array, ($final_parameters));
        # Code snippet
        my $code_snippet = 
<<"CODE_SNIPPET";
// Original code: ${original_code}
bytes32 private ${handler_name}_key;
function set_${handler_name}_key() private {
    ${handler_name}_key = keccak256("${handler_name}(${final_parameters})");
}
function${handler_function}public {
////////////////////
CODE_SNIPPET
        print {$write_fh} $code_snippet;
        next;        
    }
    #################################################################################
    #################################################################################    
    # Constructor & Signal
    if ($line =~ /constructor/) {
        print {$write_fh} $line;
        for (my $i = 0; $i <= $#signal_array; $i = $i + 1){
            my ($signal_name) = $signal_array[$i];
            my $code_snippet = 
<<"CODE_SNIPPET";
// Auto create signal
set_${signal_name}_key();
assembly {
    mstore(0x00, createsignal(sload(${signal_name}_key.slot)))
}
////////////////////
CODE_SNIPPET
            print {$write_fh} $code_snippet;        
        }
        next;    
    }

    #################################################################################
    #################################################################################
    
    # Regular line of code
    print {$write_fh} $line;
}

close $read_fh;
close $write_fh;

open($read_fh, "<", "$output_file\.temp") or die $!;
open($write_fh, ">", $output_file) or die $!;
while (my $line = <$read_fh>) {
    print {$write_fh} $line;
}

close $read_fh;
close $write_fh;
system("rm -rf $output_file\.temp");