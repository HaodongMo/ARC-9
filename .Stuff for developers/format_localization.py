# This file takes all English strings and copies them to the non-English ones.
# Existing translations are kept as-is, while strings that are missing are added, but are commented out.
# Place the file in the base directory (where lua, materials, etc. are) and run it, and it'll handle the rest.

BaseDir = "lua/arc9/common/localization/base_"
BaseFile = BaseDir + r"en.lua"
ToBeFormatted = ["de","es-es","ru","sv-se","uwu","zh-cn"]

def makeTemplate():
    with open(BaseFile, "r", encoding='utf-8') as f:
        raw = f.readlines()

    Template = []
    i = 0
    while i < len(raw):
        line = raw[i]

        if line.lstrip().startswith("L["):
            parts = line.split("=", 1)
            if len(parts) < 2:
                Template.append([False, line])
                i += 1
                continue

            key = parts[0].strip()
            value = parts[1].lstrip()

            # Handle [[ multi-line strings ]]
            if "[[" in value and "]]" not in value:
                full_value = value
                i += 1
                while i < len(raw):
                    full_value += raw[i]
                    if "]]" in raw[i]:
                        break
                    i += 1
                value = full_value

            Template.append([True, key, value])
        else:
            Template.append([False, line])

        i += 1

    return Template


for Lang in ToBeFormatted:
    print("formatting " + Lang)
    Text = []
    FormattedText = makeTemplate()

    with open(BaseDir + Lang + ".lua", "r", encoding='utf-8') as f:
        Read = f.readlines()

    i = 0
    while i < len(Read):
        line = Read[i].lstrip()

        if line.startswith("--"):
            i += 1
            continue

        if line.startswith("L["):
            parts = Read[i].split("=", 1)
            if len(parts) < 2:
                i += 1
                continue

            key = parts[0].strip()
            value = parts[1].lstrip()

            # Handle [[ multi-line strings ]]
            if "[[" in value and "]]" not in value:
                full_value = value
                i += 1
                while i < len(Read):
                    full_value += Read[i]
                    if "]]" in Read[i]:
                        break
                    i += 1
                value = full_value

            Text.append([key, value])

        i += 1

    for entry in FormattedText:
        if entry[0]:
            key = entry[1]
            found = False

            for j in Text:
                if key == j[0]:
                    entry[1] = f"{key} = {j[1]}"
                    found = True
                    break

            if not found:
                print(Lang + " missing string " + key)
                entry[1] = f"-- {key} = {entry[2]}"

    with open(BaseDir + Lang + ".lua", "w", encoding='utf-8') as f:
        for line in FormattedText:
            f.write(line[1].rstrip("\n") + "\n")

    del Text[:]
    del FormattedText[:]

print("MAKE SURE TO MANUALLY REVIEW!!!")