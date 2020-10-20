import os, glob

referenced_images = list()

def getImages(s):
    images = list()
    index = 0
    find_string = '"image": "'
    for x in range(999):
        index = s.find(find_string, index, len(s))
        if index == len(s) or index == -1:
            return images
        image = s[index+len(find_string):s.find('",', index, len(s))]
        images.append(image)
        index += 1

def getReferencesInString(string):
    images = getImages(string)
    for image in images:
        if image in referenced_images:
            pass
        else:
            referenced_images.append(image)

def getReferencesInDir(dir):
    for file in glob.glob(dir):
        if not os.path.isfile(file):
            continue
        if file.find(".py") != -1:
            continue
    
        f = open(file, "r")
        s = f.read()
        f.close()
        getReferencesInString(s)
        

def main():
    getReferencesInDir("../../materials/*")
    getReferencesInDir("../../materials/mc/*")
    getReferencesInDir("../../materials/wc/*")

    result = "";
    for image in referenced_images:
        result += str(image) + "\n"
    result = result[:-1]
    f = open("material_references.txt", "w")
    f.write(result)
    f.close()

main()

    
