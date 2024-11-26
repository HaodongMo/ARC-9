BaseDir = "../lua/arc9/common/localization/base_"
BaseFile = BaseDir + r"en.lua"
ToBeFormatted = ["de","es-es","ru","sv-se","uwu","zh-cn"]


def makeTemplate():
    with open(BaseFile, "r", encoding='utf-8') as f:
        Template = f.readlines()
    for i in range(len(Template)):
        if Template[i][:2] == "L[":
            Template[i] = [True, Template[i].split(" = ")[0],Template[i].split(" = ")[1]]
        else:
            Template[i] = [False, Template[i]]
    return Template


for Lang in ToBeFormatted:
    print("formatting " + Lang)
    Text = []
    FormattedText = makeTemplate()
    with open(BaseDir + Lang + ".lua", "r", encoding='utf-8') as f:
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
                    print(Lang + " missing string " + i[1])
                    i[1] = "-- " + i[1] + " = "+ i[2]
    with open(BaseDir + Lang + ".lua", "w", encoding='utf-8') as f:
        for line in FormattedText:
            f.write(line[1])
    del Text[:]
    del FormattedText[:]
print("MAKE SURE TO MANUALLY REVIEW!!!")
