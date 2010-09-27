#!/usr/bin/lua

-- Create a random chromosome
function random_chromosome (length)
   chromosome = ''
   for i=1,length  do
      chromosome = chromosome .. ((math.random() >0.5) and "1" or "0") 
   end
   return chromosome
end

-- Compare according to fitness
function compare(a,b)
   return fitness_of[b] < fitness_of[a]
end

-- Computes maxOnes fitness
function compute_fitness (chromosome)
   ones = 0
   for i=1,chromosome:len() do 
      ones = ones + ( (chromosome:sub(i,i) == "1") and 1 or 0 )
   end
   return ones
end

-- Spins the roulette wheel
function spin (wheel, slots ) 
   slots_for = {}
   for i=1,#wheel do 
      slots_for[i] = slots*wheel[i] 
   end
   return slots_for
end

-- Mutate a single chromosome
function mutate ( pool )
   for i=1,#pool do
      mutation_point = math.random( pool[i]:len() )
      temp = pool[i]
      pool[i] = temp:sub(1,mutation_point-1)
      pool[i] = pool[i] .. temp:sub(mutation_point,mutation_point)
      pool[i] = pool[i] .. temp:sub(mutation_point+1,temp:len())
   end
end

-- crossover 
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

chromosome_length = arg[1] or 128;
population_size = arg[2] or 32;
generations = arg[3] or 100;

print( "CL "..chromosome_length.."\nPS "..population_size.."\nGEN "..generations.."\n")

profiler.start()

population = {};
for i=1,population_size do 
    population[i] = random_chromosome( chromosome_length )
end

fitness_of = {}
best = {}
this_generation = 0

repeat 
   total_fitness = 0;
   print( "Generation "..this_generation )
   for i=1,population_size do
      if ( fitness_of[population[i]] == nil ) then
	 fitness_of[population[i]] = compute_fitness( population[i] )
      end
      total_fitness = total_fitness + fitness_of[population[i]]
   end
   table.sort( population, compare )

--[[   for i,value in ipairs(population) do
      key = table.concat( value )
      print(key,": ",fitness_of[key])
   end
]]--

   for i=1,2 do
      best[i] = population[i]  -- keep for later
   end

   wheel ={}
   for i=1,population_size do
      wheel[i] = fitness_of[population[i]]/total_fitness
   end
   slots = spin( wheel, population_size )

   pool = {}
   index = 0
   while #pool < population_size do
      p = 1 + index % #slots
      index = index+1
      
      copies = slots[p]
      for i=1,math.floor(copies) do
	 pool[#pool+1] = population[p]
      end
   end
   population = {}
   mutate( pool )
   for i = 1,population_size/2-1 do
      first = pool[math.random(#pool)];
      second = pool[math.random(#pool)];
      first_prime, second_prime = crossover( first, second)
      population[#population+1] = first_prime
      population[#population+1] = second_prime
   end
   population[#population+1] = best[1]
   population[#population+1] = best[2]
   this_generation = this_generation + 1

until ( this_generation > generations ) or (fitness_of[best[1]] >= chromosome_length ) 
profiler.stop()
print( "Best\n\t"..best[1].." -> "..fitness_of[best[1]] )
