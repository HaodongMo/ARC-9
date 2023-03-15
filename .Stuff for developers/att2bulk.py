prefix = "eft_grip_ak_*"   # Atts with this prefix in lua name will be packed. Uses wildcards ( *_ak_* )
arc = 1                      # 0 for ArcCW bulk atts, 1 for ARC9 bulk atts

import glob
import os

if arc:
    content = "local ATT = {}\n\n"
else:
    content = "local att = {}\n\n"

for attpath in glob.glob(prefix + '.lua'): # process
    attlua = open(attpath, 'r')
    content = content + "\n///////////////////////////////////////      "+ os.path.basename(attpath)[:-4] + "\n\n\n"
    if arc:
        content = content + 'ATT = {}\n\n' + attlua.read() + '\n\n\nARC9.LoadAttachment(ATT, "' + os.path.basename(attpath)[:-4] + '")\n\n'
    else:
        content = content + 'att = {}\n\n' + attlua.read() + '\n\n\nArcCW.LoadAttachmentType(att, "' + os.path.basename(attpath)[:-4] + '")\n\n'
    attlua.close() 

bulk = open(prefix[:-1] + 'bulk.lua', 'w+')
bulk.write(content)
bulk.close()