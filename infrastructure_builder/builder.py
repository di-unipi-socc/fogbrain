import random as r
f = open("infra.pl", "a")

f.write(":-dynamic node/4.\n:-dynamic link/4.\n")

nodesnumber = 400

CLOUDS = nodesnumber
ISPS = nodesnumber
CABINETS = nodesnumber
ACCESSPOINTS = nodesnumber
SMARTPHONES = nodesnumber

clouds = []
isps = []
cabinets = []
accesspoints = []
smartphones = []

def writeNodes(basename, number, caps, lista, file):
    for i in range(number):
        name = basename + str(i)
        node = "node(" + name +"," + caps +").\n"
        lista.append(name)
        f.write(node) 

def printLinks(list1, list2, qos, f):
    for n1 in list1:
        for n2 in list2:
            if n1 != n2:
                link = "link(" + n1 + ", " + n2 + ", " + qos + ").\n"
                f.write(link)

writeNodes("cloud", CLOUDS, "[ubuntu, mySQL, gcc, make], inf, []", clouds, f)
writeNodes("ispdatacentre", ISPS, "[ubuntu, mySQL], 50, []", isps, f)
writeNodes("cabinetserver", CABINETS, "[ubuntu, mySQL], 20, []", cabinets, f)
writeNodes("accesspoint", ACCESSPOINTS, "[ubuntu, gcc, make], 4, []", accesspoints, f)
writeNodes("smartphone", SMARTPHONES, "[android, gcc, make], 8, []", smartphones, f)

f.write("\n")

printLinks(clouds, clouds, "20, 1000", f)
printLinks(clouds, isps, "110, 1000", f)
printLinks(clouds, cabinets, "135, 100", f)
printLinks(clouds, accesspoints, " 148, 20", f)
printLinks(clouds, smartphones, "150, 18", f)

f.write("\n")

printLinks(isps, clouds, "110, 1000", f)
printLinks(isps, isps, "20, 1000", f)
printLinks(isps, cabinets, "25, 500", f)
printLinks(isps, accesspoints, "38, 50", f)
printLinks(isps, smartphones, "20, 1000", f)

f.write("\n")

printLinks(cabinets, clouds, "135, 100", f)
printLinks(cabinets, isps, "25, 500", f)
printLinks(cabinets, cabinets, "20, 1000", f)
printLinks(cabinets, accesspoints, "13, 50", f)
printLinks(cabinets, smartphones, "15, 35", f)

f.write("\n")

printLinks(accesspoints, clouds, "148, 3", f)
printLinks(accesspoints, isps, "38, 4", f)
printLinks(accesspoints, cabinets, "13, 4", f)
printLinks(accesspoints, accesspoints, "10, 50", f)
printLinks(accesspoints, smartphones, "2, 70", f)

f.write("\n")


printLinks(smartphones, clouds, "150, 2", f)
printLinks(smartphones, isps, "40, 2.5", f)
printLinks(smartphones, cabinets, "15, 3", f)
printLinks(smartphones, accesspoints, "2, 70", f)
printLinks(smartphones, smartphones, "15, 50", f)

f.close()