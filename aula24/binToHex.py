
#!/bin/python3
def convertToHex(codesBin):
	return list(map(lambda code: hex(int(code, 2))[2:], codesBin))

def readFile():
	with open('instructions2', 'r') as file:
		return file.readlines()

if __name__ == "__main__":
	codesHex = convertToHex(readFile())
	# codesHex = list(map(lambda code: f"{code:0>32}\n", codesHex))
	codesHex = list(map(lambda code: f"{code}\n", codesHex))
	with open('rom.hex', 'w') as file:
		for code in codesHex: file.write(code)

