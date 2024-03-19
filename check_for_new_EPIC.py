import sys
import os

filetmp = open("/mnt/NextSeq/testfolder/list_of_runs.txt","r")
all_of_it = filetmp.read()
filetmp.close()

def replace(string_to_replace,run_nbr):
    print("replacing")
    filetmp = open("/mnt/NextSeq/testfolder/Methylation_EPIC.R",mode='r')
    rscript = filetmp.read()
    filetmp.close()
    rscript2 = rscript.replace("DATEOFRUN",string_to_replace.split("_")[0]).replace("RUN_NBR",run_nbr)
    filetmp5 = open("/mnt/NextSeq/testfolder/Methylation_EPIC.R",mode='w')
    filetmp5.write(rscript2)
    filetmp5.close()
    print(rscript2)
    os.system("sudo Rscript /mnt/NextSeq/testfolder/Methylation_EPIC.R")
    print("done" + str(string_to_replace))
    filetmp6 = open("/mnt/NextSeq/testfolder/Methylation_EPIC.R",mode='w')
    filetmp6.write(rscript)
    filetmp6.close()
    #filetmp7 = open("/mnt/NextSeq/testfolder/list_of_runs.txt",mode='a')
    #filetmp7.write("\n")
    #filetmp7.write(run_nbr)
    #filetmp7.close()

def check_nbr_lines(path_to_check):
    #filetmp4 = open(path_to_check,mode='r')
    #filecontent = filetmp4.read()
    nbrlines=int(str(os.popen("wc -l " + path_to_check + "").read()).split("/")[0])
    return(nbrlines)

existing_runs = []
for i in all_of_it.split("\n"):
    existing_runs.append(i)

list_of_dirs = os.listdir("/mnt/Molpath/array_data/EPIC/")


#filetmp.close()


print(list_of_dirs)

for i in list_of_dirs:
    if(not os.path.isdir("/mnt/Molpath/array_data/EPIC/" + i)):
           print("is not path")
           continue
    if(i in existing_runs):
        print("existing run")
        continue
    else:
        final_name_2 = ""
        foo = 5
        list_of_run_info = os.listdir("/mnt/Molpath/array_data/EPIC/" + i)
        final_name = ""
        for k in list_of_run_info:
            print("k " +k)
            if("run_info_" in k):
                k = "run_info_" + k.split("run_info_")[1].split("_")[0]
                if(not(".csv" in k)):
                    k = k + ".csv"
                if(check_nbr_lines("/mnt/Molpath/array_data/EPIC/" + i + "/" + k) < 3):
                    print("no 3 lines")
                    continue
                print(k.split(".")[0] + "_1.csv")
                print("has final name")
                final_name_2 = k.split(".")[0] + "_1.csv"
                final_name = k.replace("run_info_","").replace("run_info","").split(".csv")[0]
                print(str(k))
                print("cat /mnt/Molpath/array_data/EPIC/" + i + "/" + k + " | sed \"s/;/,/g\" >/mnt/Molpath/array_data/EPIC/" + i + "/run_info_" + final_name +"_1.csv")
                if(not("backup" in k)):
                    os.system("cp /mnt/Molpath/array_data/EPIC/" + i + "/" + k +" /mnt/Molpath/array_data/EPIC/" + i + "/backup_" + k +"")
                    os.system("cat /mnt/Molpath/array_data/EPIC/" + i + "/" + k + " | sed \"s/;/,/g\" >/mnt/Molpath/array_data/EPIC/" + i + "/run_info_" + final_name +"_1.csv")
                    os.system("mv /mnt/Molpath/array_data/EPIC/" + i + "/run_info_" + final_name +"_1.csv /mnt/Molpath/array_data/EPIC/" + i + "/" + k +"")
                    break
        print("final name 2 " + final_name_2)
        print("i"+i)
        if(len(final_name_2) > 0):
            replace(final_name_2.split("run_info_")[1].replace(".csv",""),i)
            print("replaced")
            nbrpdfs=int(os.popen("ls -al /mnt/Molpath/array_data/EPIC/" + i + " | grep pdf | wc -l").read())
            if(nbrpdfs > 1):
                filetmp3 = open("/mnt/NextSeq/testfolder/list_of_runs.txt",mode='a')
                filetmp3.write("\n")
                filetmp3.write(i)
                filetmp3.close()
        else:
            print("length is 0")

        #os.system("sudo Rscript Methylation_EPIC_QC_new_WORKING.R")
