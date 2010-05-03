#!/usr/bin/perl

use strict;
use warnings;

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

map( compute_fitness( $_ ), @population );
for ( 1..$generations ) {
  my @sorted_population = sort { $b->{'fitness'} <=> $a->{'fitness'} } @population;
  my @best = @sorted_population[0,1]; # Keep for later
  print $best[0]->{'string'}, " ", $best[0]->{'fitness'}, "\n";
  my @wheel = compute_wheel( \@sorted_population );
  my @slots = spin( \@wheel, $population_size );
  my @pool;
  my $index = 0;
  do {
    my $p = $index++ % @slots;
    my $copies = $slots[$p];
    for (1..$copies) {
      push @pool, $sorted_population[$p];
    }
  } while ( @pool <= $population_size );

  @population = ();
  map( mutate($_), @pool );
  for ( my $i = 0; $i < $population_size/2 -1 ; $i++ )  {
    my $first = $pool[rand($#pool)];
    my $second = $pool[ rand($#pool)];
    
    push @population, crossover( $first, $second );
  }
  map( compute_fitness( $_ ), @population );
  push @population, @best;
}

sub compute_wheel {
  my $population = shift;
  my $total_fitness;
  map( $total_fitness += $_->{'fitness'}, @$population );
  my @wheel = map( $_->{'fitness'}/$total_fitness, @$population);
  return @wheel;
}

sub spin {
  my ( $wheel, $slots ) = @_;
  my @slots = map( $_*$slots, @$wheel );
  return @slots;
}

sub random_chromosome {
  my $length = shift;
  my $string = '';
  for (1..$length) {
    $string .= (rand >0.5)?1:0;
  }
  { string => $string,
    fitness => undef };
}

sub mutate {
  my $chromosome = shift;
  my $clone = { string => $chromosome->{'string'},
		fitness => undef };
  my $mutation_point = rand( length( $clone->{'string'} ));
  substr($clone->{'string'}, $mutation_point, 1,
	 ( substr($clone->{'string'}, $mutation_point, 1) eq 1 )?0:1 );
  return $clone;
}

sub crossover {
  my ($chrom_1, $chrom_2) = @_;
  my $chromosome_1 = { string => $chrom_1->{'string'} };
  my $chromosome_2 = { string => $chrom_2->{'string'} };
  my $length = length( $chromosome_1 );
  my $xover_point_1 = int rand( $length -1 );
  my $xover_point_2 = int rand( $length -1 );
  if ( $xover_point_2 < $xover_point_1 )  {
    my $swap = $xover_point_1;
    $xover_point_1 = $xover_point_2;
    $xover_point_2 = $swap;
  }
  $xover_point_2 = $xover_point_1 + 1 if ( $xover_point_2 == $xover_point_1 );
  my $swap_chrom = $chromosome_1;
  substr($chromosome_1->{'string'}, $xover_point_1, $xover_point_2 - $xover_point_1 + 1,
	 substr($chromosome_2->{'string'}, $xover_point_1, $xover_point_2 - $xover_point_1 + 1) );
  substr($chromosome_2->{'string'}, $xover_point_1, $xover_point_2 - $xover_point_1 + 1,
	 substr($swap_chrom->{'string'}, $xover_point_1, $xover_point_2 - $xover_point_1 + 1) );
  return ( $chromosome_1, $chromosome_2 );
}

sub compute_fitness {
  my $chromosome = shift;
  my $unos = 0;
  for ( my $i = 0; $i < length($chromosome->{'string'}); $i ++ ) {
      $unos += substr($chromosome->{'string'}, $i, 1 );
  }
  $chromosome->{'fitness'} = $unos;
}


