import sys

def correct_file(input_file,output):
    #print("infile:" + input_file)
    #print("outfile:" + output)
    filetmp = open(input_file,mode='r')
    all_of_it = filetmp.read()
    filetmp.close()
    lines = all_of_it.split("\n")
    lines.pop(116)
    lines.pop(116)
    lines.pop(116)
    lines.pop(116)
    list1 = lines[1:77] + lines[193:]
    list1[111] = "Cut-off: p-value \\textless{} 0.05"
    #if not() in list1:
    #    list1.append("Cut-off: p-value \\textless{} 0.05")
    #list1.pop(120)
    #list1.pop(120)
    filetmp = open(output,mode='w')
    all_of_it = filetmp.write("\n".join(list1))
    filetmp.close()
    print(all_of_it)


## alles bis zur 2. Tabelle (Probe) entfernen, Tabelle nur 1 mal zeigen, Cutoff zeigen
