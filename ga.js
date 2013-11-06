#!/usr/bin/env node

// Create a random chromosome
function random_chromosome (length){
    var chromosome = '';
    for ( var i = 0; i < length; i++ ){
	chromosome = chromosome + ((Math.random() >0.5)? "1": "0") ;
    }
    return chromosome;
}

/* 
-- Compare according to fitness
function compare(a,b)
   return fitness_of[b] < fitness_of[a]
end

*/

// Computes maxOnes fitness
function compute_fitness (chromosome){
    var ones = 0
    for ( var i=0; i < chromosome.length; i++ ){ 
	ones += parseInt(chromosome.charAt(i));
    }
    return ones;
}

// Mutate all chromosomes in the population
function mutate ( pool ) {
    for ( var i=0 in pool ) {
	console.log( pool[i] );
	var mutation_point = Math.floor( Math.random() * pool[i].length);
	var temp = pool[i];
	var flip_bit = (temp.substr(mutation_point,1)=='1')?"0":"1";
	pool[i] = temp.substring(0,mutation_point-1) +
	    flip_bit + 
	    temp.substring(mutation_point,temp.length) ;
	console.log( pool[i] );
    }
}

/* crossover 
function crossover ( chrom1, chrom2 )
   length = chrom1:len()
   xover_point = math.floor( math.random ( length - 1 ))
   range = 1 + math.floor( math.random ( length - xover_point ) )
   new_chrom1 = chrom1:sub(1,xover_point-1)
   new_chrom2 = chrom2:sub(1,xover_point-1)
   new_chrom1 = new_chrom1 .. chrom2:sub(xover_point,xover_point+range)
   new_chrom2 = new_chrom2 .. chrom1:sub(xover_point,xover_point+range)
   new_chrom1 = new_chrom1 .. chrom1:sub(xover_point+range+1,length)
   new_chrom2 = new_chrom2 .. chrom2:sub(xover_point+range+1,length)
   return new_chrom1, new_chrom2
end

-- Here goes the program

require "profiler"

chromosome_length = tonumber(arg[1]) or 16;
population_size = tonumber(arg[2]) or 32;
generations = tonumber(arg[3]) or 100;

print( "CL "..chromosome_length.."\nPS "..population_size.."\nGEN "..generations.."\n")

profiler.start()

math.randomseed( os.time() ) -- true randomness

population = {};
for i=1,population_size do 
    population[i] = random_chromosome( chromosome_length )
end

fitness_of = {}
best = {}
this_generation = 0

while (this_generation <= generations ) do 
   total_fitness = 0;
--   print( "Generation "..this_generation )
   best_fitness = 0
   for i=1,population_size do
      if ( fitness_of[population[i]] == nil ) then
	 fitness_of[population[i]] = compute_fitness( population[i] )
      end
      if ( fitness_of[population[i]] > best_fitness ) then
	 if best[1] then
	    best[2] = best[1]
	 end
	 best[1] = population[i]
	 best_fitness = fitness_of[population[i]]
      end
      total_fitness = total_fitness + fitness_of[population[i]]
   end

--[[   for i,value in ipairs(population) do
      key = table.concat( value )
      print(key,": ",fitness_of[key])
   end
]]--

   if (fitness_of[best[1]] >= chromosome_length ) then
      break
   end

   pool = {}
   index = 0
   while #pool < population_size do
      first = population[ math.random(#population)]
      second = population[ math.random(#population)]

      if ( fitness_of[first] > fitness_of[second] ) then
	 pool[#pool+1] = first
      else
	 pool[#pool+1] = second
      end
   end
   population = {}
   for i = 1,population_size/2-1 do
      first = pool[math.random(#pool)];
      second = pool[math.random(#pool)];
      first_prime, second_prime = crossover( first, second)
      population[#population+1] = first_prime
      population[#population+1] = second_prime
   end
   mutate( population )
   population[#population+1] = best[1]
   population[#population+1] = best[2]
   this_generation = this_generation + 1

end

profiler.stop()
print( "Best\n\t"..best[1].." -> "..fitness_of[best[1]].. "\nGeneration " .. this_generation )

*/

var population_size = 16;
var chromosome_size = 16;
var population = new Array;

for ( var i = 0; i < population_size; i ++ )  {
    var chromosome = random_chromosome( chromosome_size );
    console.log(chromosome + "->" + compute_fitness(chromosome));
    population.push( chromosome );
}
console.log('Mutando\n\n');
mutate( population );
for ( var i in population )  {
    
    console.log(population[i] + "->" + compute_fitness(population[i]));
}