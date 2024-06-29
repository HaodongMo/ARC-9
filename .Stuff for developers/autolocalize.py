BaseFile = input("Localization file: ")
Directory = input("Directory: ")
Exclude = input("Exclude: ")

import glob
import os

Dictionary = {}

with open(BaseFile, "r", encoding='utf-8') as f:
    Template = f.readlines()
    for i in range(len(Template)):
        split = Template[i].split(" = ")
        if Template[i][:2] == "L[":
            Dictionary[split[1].rstrip()] = (split[0])[2:-1]

for path in glob.iglob(Directory+'/**/*.lua',recursive = True): # process
    if len(Exclude) > 0 and Exclude in path:
        print(f"Excluded file {path}.")
        continue
    print(path)
    with open(path, 'r+') as lua:
        content = lua.read()
        for key in Dictionary:
            content = content.replace(key,f"ARC9:GetPhrase({Template[key]})")
        lua.seek(0)
        lua.write(content)

print("MAKE SURE TO MANUALLY REVIEW!!!")
