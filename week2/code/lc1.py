birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7),
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2),
         )

#(1) Write three separate list comprehensions that create three different
# lists containing the latin names, common names and mean body masses for
# each species in birds, respectively. 

# (2) Now do the same using conventional loops (you can choose to do this 
# before 1 !). 

# A nice example out out is:
# Step #1:
# Latin names:
# ['Passerculus sandwichensis', 'Delichon urbica', 'Junco phaeonotus', 'Junco hyemalis', 'Tachycineata bicolor']
# ... etc.
 
# Step #1:
# Latin name
# Method1:list comprehensions
list1=[a[0] for a in birds]
# Method2:For loop
for_loop_result1 = []
for a in birds:
    for_loop_result1.append(a[0])

print(for_loop_result1)

# Step #2:
# common names
# Method1:list comprehensions
list2=[a[1] for a in birds]
# Method2:For loop
for_loop_result2 = []
for a in birds:
    for_loop_result2.append(a[1])

print(for_loop_result1)

# Step #3:
# mean body masses
# Method1:list comprehensions
list3=[a[2] for a in birds]
# Method2:For loop
for_loop_result3 = []
for a in birds:
    for_loop_result3.append(a[2])
    
print(for_loop_result1)