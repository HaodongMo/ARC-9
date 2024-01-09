# btw this doesn't read subfolders even if you use **
import glob, os
pydir = os.getcwd()
os.chdir(input("Work dir:\n"))
with open(pydir+"/list.txt","w") as f: 
    f.writelines("{\n")
    for txt in glob.glob(input("Filter:\n")):
        print(txt)
        f.writelines(f"    [\"{txt}\"] = true,\n")
    f.writelines("}\n")
