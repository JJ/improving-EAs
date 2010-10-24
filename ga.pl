#!/usr/bin/perl

use strict;
use warnings;

use Sort::Key::Top qw(rnkeytop) ;

my $chromosome_length = shift || 16;
my $population_size = shift || 32;
my $generations = shift || 100;

print<<EOC;
CL $chromosome_length
PS $population_size
GEN $generations
EOC

my @population = map( random_chromosome( $chromosome_length ), 
		      1..$population_size );

my %fitness_of;
my ($this_generation,@best);
while  ( $this_generation++ <= $generations ) {
    my $total_fitness = 0;
    map( ((!$fitness_of{$_})?compute_fitness( $_ ):1) 
	 && ( $total_fitness += $fitness_of{$_} ), @population );
    @best = rnkeytop { $fitness_of{$_} } 2 => @population;
    my @wheel = map( $fitness_of{$_}/$total_fitness, @population);
    my @slots = spin( \@wheel, $population_size );
    my @pool;
    my $index = 0;
    do {
	my $p = $index++ % @slots;
	my $copies = $slots[$p];
	for (1..$copies) {
	    push @pool, $population[$p];
	}
    } while ( @pool <= $population_size );
    
    @population = ();
    for ( my $i = 0; $i < $population_size/2 -1 ; $i++ )  {
	my $first = $pool[rand($#pool)];
	my $second = $pool[rand($#pool)];
	
	push @population, crossover( $first, $second );
    }
    map( $_ = mutate($_), @population );
    
    push @population, @best;
    last if ($fitness_of{$best[0]} >= $chromosome_length  );
}

print "Best ", $best[0], " fitness ", $fitness_of{$best[0]}, 
    "\nGeneration ", $this_generation, "\n";

#-------------------------------------------------------------
sub random_chromosome {
  my $length = shift;
  my $string = '';
  for (1..$length) {
    $string .= (rand >0.5)?1:0;
  }
  $string;
}

sub spin {
   my ( $wheel, $slots ) = @_;
   my @slots = map( $_*$slots, @$wheel );
   return @slots;
}

sub mutate {
  my $chromosome = shift;
  my $mutation_point = rand( length( $chromosome ));
  substr($chromosome, $mutation_point, 1,
	 ( substr($chromosome, $mutation_point, 1) eq 1 )?0:1 );
  return $chromosome;
}

sub crossover {
  my ($chromosome_1, $chromosome_2) = @_;
  my $length = length( $chromosome_1 );
  my $xover_point_1 = int rand( $length - 2 );
  my $range = 1 + int rand ( $length - $xover_point_1 );
  my $swap_chrom = $chromosome_1;
  substr($chromosome_1, $xover_point_1, $range,
	 substr($chromosome_2, $xover_point_1, $range) );
  substr($chromosome_2, $xover_point_1, $range,
	 substr($swap_chrom, $xover_point_1, $range) );
  return ( $chromosome_1, $chromosome_2 );
}

sub compute_fitness {
  my $chromosome = shift;
  my $copy_of = $chromosome;
  $fitness_of{$chromosome} = ($copy_of =~ tr/1/0/);
}


