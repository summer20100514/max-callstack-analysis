#!/usr/bin/perl -w
# avstack.pl: AVR stack checker
# Copyright (C) 2013 Daniel Beer <dlbeer@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for
# any purpose with or without fee is hereby granted, provided that the
# above copyright notice and this permission notice appear in all
# copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
# WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
# DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
# PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
# TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# Usage
# -----
#
# This script requires that you compile your code with -fstack-usage.
# This results in GCC generating a .su file for each .o file. Once you
# have these, do:
#
#    ./avstack.pl <object files>
#
# This will disassemble .o files to construct a call graph, and read
# frame size information from .su. The call graph is traced to find, for
# each function:
#
#    - Call height: the maximum call height of any callee, plus 1
#      (defined to be 1 for any function which has no callees).
#
#    - Inherited frame: the maximum *inherited* frame of any callee, plus
#      the GCC-calculated frame size of the function in question.
#
# Using these two pieces of information, we calculate a cost (estimated
# peak stack usage) for calling the function. Functions are then listed
# on stdout in decreasing order of cost.
#
# Functions which are recursive are marked with an 'R' to the left of
# them. Their cost is calculated for a single level of recursion.
#
# The peak stack usage of your entire program can usually be estimated
# as the stack cost of "main", plus the maximum stack cost of any
# interrupt handler which might execute.
#
#
# Note by summerxu
# ----------------
# armstack.pl is partially rewritten by summerxu(<xuwj1991@foxmail.com>).
# it's mainly based on avstack.pl and max call chains can be shown now.

use strict;
use Data::Dumper;
use List::MoreUtils 'uniq';

# Configuration: set these as appropriate for your architecture/project.

#my $objdump = "avr-objdump";
#my $call_cost = 4;
my $objdump = "/opt/arm/gcc-arm-none-eabi-9/bin/arm-none-eabi-objdump";
my $call_cost = 0;

# First, we need to read all object and corresponding .su files. We're
# gathering a mapping of functions to callees and functions to frame
# sizes. We're just parsing at this stage -- callee name resolution
# comes later.

my %frame_size;     # "func@file" -> size
my %call_graph;     # "func@file" -> {callees}
my %addresses;      # "addr@file" -> "func@file"

my %global_name;    # "func" -> "func@file"
my %ambiguous;      # "func" -> 1

my %call_chain;

foreach (@ARGV) {
    # Disassemble this object file to obtain a callees. Sources in the
    # call graph are named "func@file". Targets in the call graph are
    # named either "offset@file" or "funcname". We also keep a list of
    # the addresses and names of each function we encounter.
    my $objfile = $_;
    my $source;

    open(DISASSEMBLY, "$objdump -dr $objfile|") || die "Can't disassemble $objfile";
    while (<DISASSEMBLY>) {
    chomp;

        if (/^([0-9a-fA-F]+) <(.*)>:/) {
            my $a = $1;
            my $name = $2;
            #printf("### address %s, function name %s\n", $a, $name);
            $source = "$name\@$objfile";
            $call_graph{$source} = {};
            @{$call_chain{$source}} = [];
            $ambiguous{$name} = 1 if defined($global_name{$name});
            $global_name{$name} = "$name\@$objfile";

            $a =~ s/^0*//;
            $addresses{"$a\@$objfile"} = "$name\@$objfile";
        }

        if (/: R_[A-Za-z0-9_]+_CALL[ \t]+(.*)/ || /: R_[A-Za-z0-9_]+_JUMP.*[ \t]+(.*)/) {
            my $t = $1;
            if ($t eq ".text") {
                $t = "\@$objfile";
            } elsif ($t =~ /^\.text\+0x(.*)$/) {
                $t = "$1\@$objfile";
            }
            #printf("### callee %s\n", $t);
            $call_graph{$source}->{$t} = 1;
            #print Dumper(\%call_graph);
        }
    }
    close(DISASSEMBLY);

    # Extract frame sizes from the corresponding .su file.
    if ($objfile =~ /^(.*).o$/) {
        my $sufile = "$1.su";

        open(SUFILE, "<$sufile") || die "Can't open $sufile";
        while (<SUFILE>) {
            if (/^.*:([^\t ]+)[ \t]+([0-9]+)/) {
                $frame_size{"$1\@$objfile"} = $2 + $call_cost;
                #printf("### function %s, stack %s\n", $1, $2);
            }
        }
        close(SUFILE);
    }
}

# In this step, we enumerate each list of callees in the call graph and
# try to resolve the symbols. We omit ones we can't resolve, but keep a
# set of them anyway.

my %unresolved;

foreach (keys %call_graph) {
    my $from = $_;
    my $callees = $call_graph{$from};
    my %resolved;

    foreach (keys %$callees) {
        my $t = $_;

        if (defined($addresses{$t})) {
            $resolved{$addresses{$t}} = 1;
        } elsif (defined($global_name{$t})) {
            $resolved{$global_name{$t}} = 1;
            warn "Ambiguous resolution: $t" if defined ($ambiguous{$t});
        } elsif (defined($call_graph{$t})) {
            $resolved{$t} = 1;
        } else {
            $unresolved{$t} = 1;
        }
    }

    $call_graph{$from} = \%resolved;
}

#print Dumper(\%call_graph);

# Create fake edges and nodes to account for dynamic behaviour.
$call_graph{"INTERRUPT"} = {};

foreach (keys %call_graph) {
    $call_graph{"INTERRUPT"}->{$_} = 1 if /^__vector_/;
}

# Trace the call graph and calculate, for each function:
#
#    - inherited frames: maximum inherited frame of callees, plus own
#      frame size.
#    - height: maximum height of callees, plus one.
#    - recursion: is the function called recursively (including indirect
#      recursion)?

my %has_caller;
my %visited;
my %total_cost;
my %call_depth;
my @visited_path;

sub trace {
    my $f = shift;
    #print " shift: $f\n";
    my @chain;
    my $max_depth = 0;
    my $max_frame = 0;
    my @inner_chain;

    push @visited_path, $f;
    my @path_uniq = uniq @visited_path;
    if (scalar(@visited_path) != scalar(@path_uniq)) {
        #print "$f Recursive!!!\n";
        $visited{$f} = "R";
        pop @visited_path;
        return @chain;
    }

    if ($visited{$f}) {
        #print "$f visited before, return chain:\n";
        #print Dumper(\@{$call_chain{$f}});
        #print "\n\n";
        pop @visited_path;
        return @{$call_chain{$f}};
    }

    my $targets = $call_graph{$f} || die "Unknown function: $f";
    
    #print "outer from file $f\n";
    #print "its callees: \n";
    #print Dumper(\%$targets);
    
    if (defined($targets)) {
        foreach (keys %$targets) {
            my $t = $_;
            $has_caller{$t} = 1;
            @inner_chain = trace($t);

            #print "Inner from $t : ";
            #print Dumper(\reverse @inner_chain);
            #print "\n\n";

            my $is = $total_cost{$t};
            my $d = $call_depth{$t};

            if (defined $is && $is > $max_frame) {
                $max_frame = $is;
                @chain = @inner_chain;
            }
            if (defined $d && $d > $max_depth) {
                $max_depth = $d;
            }
        }
    }
    $visited{$f} = "?" if ((defined $visited{$f} && $visited{$f} ne "R") || !defined $visited{$f});
    push @chain, $f;
    $call_depth{$f} = $max_depth + 1;
    $total_cost{$f} = $max_frame + ($frame_size{$f} || 0);
    #print "add $f stack size $frame_size{$f}, total $total_cost{$f}\n";
    #print "visited path @visited_path \n\n";
    pop @visited_path;
    #print "chain from $f: ";
    #print Dumper(\reverse @chain);
    #print "\n\n";
    @{$call_chain{$f}} = @chain;
    return @chain;
}

foreach (keys %call_graph) { 
    trace($_);
    #print "call chain:\n"; 
    #print Dumper(\%call_chain); 
};

# Now, print results in a nice table.
printf "  %-42s %8s %8s %8s\n",
    "Func", "Cost", "Frame", "Height";
print "------------------------------------";
print "------------------------------------\n";

my $max_iv = 0;
my $main = 0;

#print "visited: \n";
#print Dumper(\%visited);
foreach (keys %visited) {
    $visited{$_} = " " if $visited{$_} eq "?";
}

foreach (sort { $total_cost{$b} <=> $total_cost{$a} } keys %visited) {
    my $name = $_;

    if (/^(.*)@(.*)$/) {
        $name = $1 unless $ambiguous{$name};
    }

    my $tag = $visited{$_};
    my $cost = $total_cost{$_};

    $name = $_ if $ambiguous{$name};
    $tag = ">" unless $has_caller{$_};

    if (/^__vector_/) {
        $max_iv = $cost if $cost > $max_iv;
    } elsif (/^main@/) {
        $main = $cost;
    }

    if ($ambiguous{$name}) { $name = $_; }

    printf "%s %-42s %8d %8d %8d\n", $tag, $name, $cost,
    $frame_size{$_} || 0, $call_depth{$_};
}

print "\n\n";

#print Dumper(\%call_chain);
foreach (sort { $total_cost{$b} <=> $total_cost{$a} } keys %visited) {
    my @chain = reverse @{$call_chain{$_}};
    my $level = 2;
    foreach (@chain) {
        my $name = $_;
        if (/^(.*)@(.*)$/) {
            $name = $1 unless $ambiguous{$name};
        }
        if ($level == 2) {
            print "## Chain from $name, Cost ($total_cost{$_})\n";
            print "------------------------------------";
            print "------------------------------------\n";
        }
        print ' ' x $level, ">", "$name ($frame_size{$_})", "\n" if defined $frame_size{$_};
        $level = $level + 4;
    }
    print "\n";
}

printf "Peak execution estimate (main + worst-case IV):\n  main = %d, worst IV = %d, total = %d\n",
      $total_cost{$global_name{"main"}},
      $total_cost{"INTERRUPT"},
      $total_cost{$global_name{"main"}} + $total_cost{"INTERRUPT"} 
      if defined $global_name{"main"} && defined $total_cost{"INTERRUPT"};

print "\n";

print "The following functions were not resolved:\n";
foreach (keys %unresolved) { print "  $_\n"; }
#!/usr/bin/perl -w
# avstack.pl: AVR stack checker
# Copyright (C) 2013 Daniel Beer <dlbeer@gmail.com>
