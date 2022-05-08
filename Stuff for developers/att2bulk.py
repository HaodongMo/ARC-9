prefix = "eft_charge_ak_*"   # Atts with this prefix in lua name will be packed. Uses wildcards ( *_ak_* )
arc = 1                      # 0 for ArcCW bulk atts, 1 for ARC-9 bulk atts

import glob
import os

if arc:
    content = "local ATT = {}\n\n"
else:
    content = "local att = {}\n\n"

for attpath in glob.glob(prefix + '.lua'): # process
    attlua = open(attpath, 'r')
    if arc:
        content = content + 'ATT = {}\n\n' + attlua.read() + '\n\nARC9.LoadAttachment(ATT, "' + os.path.basename(attpath) + '")\n\n'
    else:
        content = content + 'att = {}\n\n' + attlua.read() + '\n\nArcCW.LoadAttachmentType(att, "' + os.path.basename(attpath) + '")\n\n'
    attlua.close() 

bulk = open(prefix + 'bulk.lua', 'w+')
bulk.write(content)
bulk.close()