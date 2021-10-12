birds = (('Passerculus sandwichensis', 'Savannah sparrow', 18.7),
         ('Delichon urbica', 'House martin', 19),
         ('Junco phaeonotus', 'Yellow-eyed junco', 19.5),
         ('Junco hyemalis', 'Dark-eyed junco', 19.6),
         ('Tachycineata bicolor', 'Tree swallow', 20.2),
         )

# Birds is a tuple of tuples of length three: latin name, common name, mass.
# write a (short) script to print these on a separate line or output block by species
#
# A nice example output is:
#
# Latin name: Passerculus sandwichensis
# Common name: Savannah sparrow
# Mass: 18.7
# ... etc.

# Hints: use the "print" command! You can use list comprehensions!

# Answer
# Method1: For loop
for a in birds:
    print("Latin name:", a[0])
    print("Common name:", a[1])
    print("Mass:", a[2], "\n")
# Method2: List Comprehensions
[print ("Latin name:", x, "\n", "Common name:", y,"\n","Mass:", z, "\n") for  (x,y,z) in birds]
