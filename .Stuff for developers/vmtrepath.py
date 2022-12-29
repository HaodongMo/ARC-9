oldpath = 'models/weapons/arccw/your gun path here/'
newpath = 'models/weapons/arc9/your gun path here/'


import glob
for txt in glob.glob('*.vmt'): # process
    vmt = open(txt, 'r')
    text = vmt.read().replace(oldpath, newpath)
    vmt.close() 
    vmt2 = open(txt, 'w')
    vmt2.write(text)
    vmt2.close()