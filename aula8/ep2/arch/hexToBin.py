#!/bin/python3
def convertToBin(codesHex):
	return list(map(lambda code: bin(int(code, 16))[2:], codesHex))

def readFile():
	with open('rom.hex', 'r') as file:
		return file.readlines()

def formatBin(code):
	charList = list(code);
	charList.insert(26, "_")
	charList.insert(28, "_")
	charList.insert(17, "_")
	charList.insert(21, "_")
	charList.insert(27, "_")
	if (int(charList[30]) == 0):
		charList.insert(1, "_")
		charList.insert(3, "_")
		charList.insert(9, "_")
		charList.insert(15, "_")
	else:
		charList.insert(12, "_")
	return ''.join(charList)

if __name__ == "__main__":
	codesBin = convertToBin(readFile())
	codesBin = list(map(lambda code: f"{code:0>32}\n", codesBin))
	codesBin = list(map(formatBin, codesBin))
	with open('rom.bin', 'w') as file:
		for code in codesBin: file.write(code)

