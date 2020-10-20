import os, glob
import _generateReferences

m_referenced_images = list()
m_images = list()

def generateReferences():
    _generateReferences.main()
    if os.path.exists("_generateReferences.pyc"):
      os.remove("_generateReferences.pyc")

def listToString(l):
    return "\n".join(l)

def stringToList(s):
    return s.split("\n")

def defineReferencedImages(tf):
    f = open(tf, "r")
    s = f.read()
    f.close()
    m_referenced_images.extend(stringToList(s))

def defineImages(dir):
    for file in glob.glob(dir):
        if not os.path.isfile(file) or file.find(".iwi") == -1:
            continue
        filename = os.path.splitext(os.path.basename(file))[0]
        m_images.append(filename)
        

def getImagesThatAreNotReferencedButInDirectory():
    images = list()
    for image in m_images:
        if image in m_referenced_images:
            pass
        else:
            images.append(image)
    return images

def getImagesThatAreReferencedButNotInDirectory():
    referenced_images = list()
    for referenced_image in m_referenced_images:
        if referenced_image in m_images:
            pass
        else:
            referenced_images.append(referenced_image)
    return referenced_images

ptext = ""
def printL(p):
    print p
    global ptext
    ptext += str(p + "\n")

def main():
    generateReferences()
    
    defineReferencedImages("material_references.txt")
    defineImages("../../images/*")
    
    images_1 = getImagesThatAreNotReferencedButInDirectory()
    images_2 = getImagesThatAreReferencedButNotInDirectory()

    #printL("REFERENCED IMAGES:")
    #printL(listToString(m_referenced_images))
    #printL("------------------------------------------------------------------")
    #printL("IMAGES:")
    #printL(listToString(m_images))
    #printL("------------------------------------------------------------------")
    printL("Images that are not referenced in materials, but in the images folder:")
    printL(listToString(images_1))
    printL("------------------------------------------------------------------")
    printL("Images that are referenced in materials, but not in the images folder:")
    printL(listToString(images_2))
    printL("------------------------------------------------------------------")

    f = open("imagesChecked.txt", "w")
    f.write(ptext)
    f.close()

main()
