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
    # Handler declaration
    if ($line =~ /handler\s/) {
        # Get handler prototype and remove spaces.
        my ($handler_prototype) = $line =~ /handler\s+(.+)\;/;
        $handler_prototype =~ s/\s+//g;
        # Get handler name.
        my ($handler_name) = $line =~ /handler\s+(.+)\(/;
        # Code snippet that represents the handler.
        my $code_snippet = 
<<"CODE_SNIPPET";
// Original code: handler ${handler_name};
bytes32 private ${handler_name}_key;
function set_${handler_name}_key() private {
    ${handler_name}_key = keccak256("${handler_prototype}");
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
        my ($handler_name) = $line =~ /\s*(.+)\./;
        my ($signal_prototype) = $line =~ /"(.+)"/;
        my ($arg_string) = $line =~ /bind\((.+)\)/;
        $arg_string =~ s/\s+//g;
        $arg_string =~ s/"(.+)"//g;
        my @arg_arr = split(',', $arg_string);
        my $code_snippet = 
<<"CODE_SNIPPET";
// Original code: ${handler_name}.bind(${arg_string}"$signal_prototype");
bytes32 ${handler_name}_signal_prototype_hash = keccak256("${signal_prototype}");
assembly {
    mstore(
        0x00,
        sigbind(
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
    # Detach
    if ($line =~ /\.detach\(/) {
        my ($handler_name) = $line =~ /\s*(.+)\./;
        my ($signal_prototype) = $line =~ /"(.+)"/;
        my ($arg_string) = $line =~ /detach\((.+)\)/;
        $arg_string =~ s/\s+//g;
        $arg_string =~ s/"(.+)"//g;
        my @arg_arr = split(',', $arg_string);
        my $code_snippet = 
<<"CODE_SNIPPET";
// Original code: ${handler_name}.detach(${arg_string}"$signal_prototype");
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