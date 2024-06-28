BaseFile = input("Localization file: ")
Directory = input("Directory: ")
Exclude = input("Exclude: ")

import glob
import os

def makeTemplate():
    with open(BaseFile, "r", encoding='utf-8') as f:
        Template = f.readlines()
        Dictionary = {}
    for i in range(len(Template)):
        split = Template[i].split(" = ")
        if Template[i][:2] == "L[":
            Dictionary[split[1].rstrip()] = (split[0])[2:-1]
    return Dictionary

# print(makeTemplate())

for path in glob.glob(Directory+'*.lua'): # process
    Template = makeTemplate()
    if Exclude in path:
        print(f"Excluded file {path}.")
        continue
    with open(path, 'r+') as lua:
        content = lua.read()
        for key in Template:
            content = content.replace(key,f"ARC9:GetPhrase({Template[key]})")
        lua.seek(0)
        lua.write(content)

print("MAKE SURE TO MANUALLY REVIEW!!!")
