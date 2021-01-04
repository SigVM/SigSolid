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
    # Create handler
    if ($line =~ /\.create_handler\(/) {
        my ($handler_name) = $line =~ /\s*(.+)\./;
        my ($method_prototype) = $line =~ /"(.+)"/;
        my ($arg_string) = $line =~ /create_handler\((.+)\)/;
        $arg_string =~ s/\s+//g;
        $arg_string =~ s/"(.+)"//g;
        my @arg_arr = split(',', $arg_string);
        my $code_snippet = 
<<"CODE_SNIPPET";
// Original code: ${handler_name}.create_handler("$method_prototype"$arg_string);
set_${handler_name}_key();
bytes32 ${handler_name}_method_hash = keccak256("$method_prototype");
uint ${handler_name}_gas_limit = $arg_arr[1];
uint ${handler_name}_gas_ratio = $arg_arr[2];
assembly {
    mstore(
        0x00, 
        createhandler(
            sload(${handler_name}_key.slot), 
            ${handler_name}_method_hash, 
            ${handler_name}_gas_limit, 
            ${handler_name}_gas_ratio
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
    # Delete handler
    if ($line =~ /\.delete_handler\(/) {
        my ($handler_name) = $line =~ /\s+(.+)\./;
        my $code_snippet = 
<<"CODE_SNIPPET";
// Original code: ${handler_name}.delete_handler();
${handler_name}_key = 0;
assembly {
    mstore(0x00, deletehandler(sload(${handler_name}_key.slot)))
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
        my ($arg_string) = $line =~ /emit\((.+)\)/;
        $arg_string =~ s/\s+//g;
        $arg_string =~ s/\)\.(.+)//g;
        my @arg_arr = split(',', $arg_string);
        my ($delay_value) = $line =~ /delay\((.+)\)/;
        my $code_snippet_with_args = 
<<"CODE_SNIPPET";
// Original code: ${signal_name}.emit(${arg_string}).delay($delay_value);
bytes memory abi_encoded_${signal_name}_data = abi.encode($arg_string);
// This length is measured in bytes and is always a multiple of 32.
uint abi_encoded_${signal_name}_length = abi_encoded_${signal_name}_data.length;
assembly {
    mstore(
        0x00,
        sigemit(
            sload(${signal_name}_key.slot), 
            abi_encoded_${signal_name}_data,
            abi_encoded_${signal_name}_length,
            $delay_value
        )
    )
}
////////////////////
CODE_SNIPPET
        my $code_snippet_wo_args = 
<<"CODE_SNIPPET";
// Original code: ${signal_name}.emit().delay($delay_value);
assembly {
    mstore(
        0x00,
        sigemit(
            sload(${signal_name}_key.slot), 
            0,
            0,
            $delay_value
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
        my ($signal_parameter) = "";
        for (my $i = 1; $i < $#arg_arr-1; $i = $i + 1){
            $signal_parameter = $signal_parameter.$arg_arr[$i].",";
        }
        $signal_parameter = $signal_parameter.$arg_arr[$#arg_arr-1];
        $signal_parameter = substr($signal_parameter, index($signal_parameter, ".")+1);
        my ($ratio_parameter) = $arg_arr[$#arg_arr];     
        my ($ratio) = $ratio_parameter * 100 + 100;
        my ($method_prototype);
        for (my $i = 0; $i <= $#handler_name_array; $i = $i + 1){
            if($handler_name eq $handler_name_array[$i]){
                $method_prototype = $handler_name_array[$i]."(".$handler_types_array[$i].")";
            }
        }
        my $code_snippet = 
<<"CODE_SNIPPET";
// Original code: ${line}
set_${handler_name}_key();
bytes32 ${handler_name}_method_hash = keccak256("${method_prototype}");
uint ${handler_name}_gas_limit = 100000000;
uint ${handler_name}_gas_ratio = $ratio;
bytes32 ${handler_name}_signal_prototype_hash = keccak256("${signal_parameter}");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(${handler_name}_key.slot),
            ${handler_name}_method_hash, 
            ${handler_name}_gas_limit, 
            ${handler_name}_gas_ratio,
            ${address_parameter},
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
    # Detach
    if ($line =~ /\.detach\(/) {
        my $original_code = $line;
        $original_code =~ s/\s+//g;
        my ($handler_name) = $line =~ /\s*(.+)\./;
        my ($signal_prototype) = "";
        my ($arg_string) = $line =~ /detach\((.+)\)/;
        $arg_string =~ s/\s+//g;
        $arg_string =~ s/"(.+)"//g;
        my @arg_arr = split(',', $arg_string);
        for (my $i = 1; $i < $#arg_arr; $i = $i + 1){
            $signal_prototype = $signal_prototype.$arg_arr[$i].",";
        }
        $signal_prototype = $signal_prototype.$arg_arr[$#arg_arr];
        $signal_prototype = substr($signal_prototype, index($signal_prototype, ".")+1);
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
        my @handler_parameter_arr = split(',', $handler_parameters);
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