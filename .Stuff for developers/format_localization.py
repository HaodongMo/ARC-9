BaseDir = r"C:\Program Files (x86)\steam\steamapps\common\GarrysMod\garrysmod\addons\ARC-9\lua\arc9\common\localization\\"
BaseFile = BaseDir + r"base_en.lua"
ToBeFormatted = [
    "base_de.lua",
    "base_es-es.lua",
    "base_ru.lua",
    "base_sv-se.lua",
    "base_uwu.lua",  # Real
    "base_zh-cn.lua"
]


def makeTemplate():
    with open(BaseFile, "r", encoding='utf-8') as f:
        Template = f.readlines()
    for i in range(len(Template)):
        if Template[i][:2] == "L[":
            Template[i] = [True, Template[i].split(" ")[0]]
        else:
            Template[i] = [False, Template[i]]
    return Template


for Lang in ToBeFormatted:
    print("formatting "+Lang)
    Text = []
    FormattedText = makeTemplate()
    with open(BaseDir+Lang, "r", encoding='utf-8') as f:
        Read = f.readlines()
    for i in range(len(Read)):
        if Read[i][:2] == "L[":
            Text.append([Read[i].split(" ")[0], Read[i].split("=")[1]])
    for i in FormattedText:
        if i[0]:
            for j in Text:
                if i[1] == j[0]:
                    i[1] = i[1] + " =" + j[1]
                    break
                if j == Text[-1]:
                    print(Lang+" missing string "+i[1])
                    i[1] = "-- "+i[1]+" = \"PLEASE TRANSLATE\"\n"
    with open(BaseDir+Lang, "w", encoding='utf-8') as f:
        for line in FormattedText:
            f.write(line[1])
    del Text[:]
    del FormattedText[:]
input("Press Enter to continue")
