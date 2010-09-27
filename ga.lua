#!/usr/bin/lua

-- Create a random chromosome
function random_chromosome (length)
   chromosome = {}
   for i=1,length  do
      chromosome[i] = (math.random() >0.5) and 1 or 0 
   end
   return chromosome
end

-- Compare according to fitness
function compare(a,b)
   return fitness_of[table.concat(b)] < fitness_of[table.concat(a)]
end

-- Deep copy array
function copy_of(a)
   local b = {}
   for key, value in ipairs(a) do
      b[key]=value
   end
   return b
end

-- Computes maxOnes fitness
function compute_fitness (chromosome)
   ones = 0
   for i=1,#chromosome do 
      ones = ones + chromosome[i]
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
      mutation_point = math.random( table.getn(pool[i] ))
      pool[i][ mutation_point ]  =  ( (pool[i][mutation_point] == 1) and 0 or 1 )
   end
end

-- crossover 
function crossover ( chrom1, chrom2 )
   length = table.getn( chrom1 )
   xover_point = math.floor( math.random ( length - 1 ))
   range = 1 + math.floor( math.random ( length - xover_point ) )
   new_chrom1 = {}
   new_chrom2 = {}
   for i = 1,xover_point-1 do
      new_chrom1[i] = chrom1[i]
      new_chrom2[i] = chrom2[i]
   end
   for i = xover_point,xover_point+range do
      new_chrom1[i] = chrom2[i]
      new_chrom2[i] = chrom1[i]
   end
   for i = xover_point+range+1,length do
      new_chrom1[i] = chrom1[i]
      new_chrom2[i] = chrom2[i]
   end
--   print("X ".. table.concat(chrom1) .. " " .. table.concat(chrom2) .. "\n  " .. table.concat(new_chrom1).. " " .. table.concat(new_chrom2) )
   return new_chrom1, new_chrom2 
end

-- Here goes the program

chromosome_length = arg[1] or 128;
population_size = arg[2] or 32;
generations = arg[3] or 100;

print( "CL "..chromosome_length.."\nPS "..population_size.."\nGEN "..generations.."\n")

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
      key = table.concat(population[i])
      if ( fitness_of[key] == nil ) then
	 fitness_of[key] = compute_fitness( population[i] )
      end
      total_fitness = total_fitness + fitness_of[key]
   end
   table.sort( population, compare )

--[[   for i,value in ipairs(population) do
      key = table.concat( value )
      print(key,": ",fitness_of[key])
   end
]]--

   for i=1,2 do
      best[i] = copy_of( population[i] ) -- keep for later
--      print( "B", i, " ", table.concat(best[i] ))
   end

   wheel ={}
   for i=1,population_size do
      wheel[i] = fitness_of[table.concat(population[i])]/total_fitness
   end
   slots = spin( wheel, population_size )

   pool = {}
   index = 0
   while #pool < population_size-1 do
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
      first = pool[math.random(table.getn(pool))];
      second = pool[math.random(table.getn(pool))];
      
      first_prime, second_prime = crossover( first, second)
      population[#population+1] = first_prime
      population[#population+1] = second_prime
   end
   population[#population+1] = best[1]
   population[#population+1] = best[2]
   this_generation = this_generation + 1

until ( this_generation > generations ) or (fitness_of[table.concat(best[1])] >= chromosome_length ) 

print( "Best\n\t"..table.concat(best[1]).." -> "..fitness_of[table.concat(best[1])] )
