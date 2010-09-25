#!/usr/bin/perl

use strict;
use warnings;

use Sort::Key::Top qw(rnkeytop) ;

my $chromosome_length = shift || 5;
my $population_size = shift || 128;
my $generations = shift || 200;
use constant PI2    => 8 * atan2(1, 1);
use constant RASTRIGIN_OPTIMUM => 0;
use constant RASTRIGIN_A => 10;
use constant RASTRIGIN_BOUNDS => 5.12;
use constant RASTRIGIN_BOUNDS2 => 5.12*5.12;

print<<EOC;
CL $chromosome_length
PS $population_size
GEN $generations
EOC

my @population = map( random_chromosome( $chromosome_length , -5.12, 10.24), 
		      1..$population_size );

my $max_rast = $chromosome_length*RASTRIGIN_BOUNDS2;
my ($this_generation,@best);
do {
    my $total_fitness = 0;
    map( ((!$_->{'fitness'})?compute_fitness( $_ ):1) 
	 && ( $total_fitness += $_->{'fitness'} ), 
	 @population );
    @best = rnkeytop { $_->{'fitness'} } 2 => @population;
    my @wheel = map( $_->{'fitness'}/$total_fitness, @population);
    my @slots = spin( \@wheel, $population_size );
    my @pool;
    my $index = 0;
    do {
	my $p = $index++ % @slots;
	my $copies = $slots[$p];
	for (1..$copies) {
	    push @pool, copy_of($population[$p]);
	}
    } while ( @pool <= $population_size );
    
    @population = ();
    map( mutate($_), @pool );
    for ( my $i = 0; $i < $population_size/2 -1 ; $i++ )  {
	my $first = $pool[rand($#pool)];
	my $second = $pool[rand($#pool)];
	
	push @population, crossover( $first, $second );
    }
    
    push @population, @best;
    my $best = join( ";", @{$best[0]->{'vector'}} );
    print<<EOC;
Best: $best
  Fitness $best[0]->{'fitness'}
EOC
} while ( ( $this_generation++ < $generations ) &&
	  ($best[0]->{'fitness'} > RASTRIGIN_OPTIMUM ) );

my $best = join( ";", @{$best[0]->{'vector'}} );
print<<EOC;
Finished after $generations generations
Best: $best
  Fitness $best[0]->{'fitness'}
EOC

# ------------------------------

sub random_chromosome {
  my $length = shift;
  my $min = shift || -1;
  my $range = shift || 2;
  my @vector = ();
  for (1..$length) {
      push @vector, $min + rand($range);
  }
  return { vector => \@vector,
	   fitness => undef };
}

sub spin {
   my ( $wheel, $slots ) = @_;
   my @slots = map( $_*$slots, @$wheel );
   return @slots;
}

sub copy_of {
    my $chromosome = shift;
    my @vector;
    push @vector, @{$chromosome->{'vector'}};
    return { fitness => $chromosome->{'fitness'},
	     vector => \@vector };
}

sub mutate {
  my $chromosome = shift;
  my $width = shift || 2;
  my $mutation_point = rand( @{$chromosome->{'vector'}} );
  $chromosome->{'vector'}->[$mutation_point] += -($width/2)+rand($width);
  $chromosome->{'fitness'} = undef;
}

sub crossover {
  my ($chromosome_1, $chromosome_2) = @_;
  my $length = @{$chromosome_1->{'vector'}};
  my $xover_point_1 = int rand( $length - 2 );
  my $range = 1 + int rand ( $length - $xover_point_1 );
  my @swap_chrom = @{$chromosome_1->{'vector'}};
  for ( my $i = $xover_point_1; $i < $xover_point_1+$range; $i ++ ) {
      $chromosome_1->{'vector'}->[$i] = $chromosome_2->{'vector'}->[$i];
      $chromosome_2->{'vector'}->[$i] = $swap_chrom[$i];
  }
  $chromosome_1->{'fitness'} = $chromosome_1->{'fitness'} = undef;
  return ( $chromosome_1, $chromosome_2 );
}

sub compute_fitness {
  my $chromosome = shift;
  my $size = @{$chromosome->{'vector'}};
  my $fitness = RASTRIGIN_A*$size;
  my @array = @{$chromosome->{'vector'}};
  for ( my $i = 0; $i < $size; $i ++ ) {
    $fitness += $array[$i]*$array[$i]- RASTRIGIN_A *cos(PI2*$array[$i]);
  }
  $chromosome->{'fitness'} = $max_rast-$fitness;
}


