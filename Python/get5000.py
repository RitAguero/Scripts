import re

wordlist = [None] * 6000
worddesc = [None] * 6000

def remove_page(word_id):
	if (len(word_id) > 4):
		return int(word_id[:-3])
	return int(word_id)


with open('spanish5000.txt') as f:
	for line in f:
		line = line.strip()
		m1 = re.fullmatch(r"(\S+)\s+(\D+(?:3rd|)\D+?)\s+(\d+)\s*(\s*|Alphabet.*)",line)
		if (m1 is not None):
			word_n = remove_page(m1.group(3))
			wordlist[word_n] = m1.group(1)
			worddesc[word_n] = m1.group(2)
		else:
			m2 = re.fullmatch(r"(\S+)\s+(\D+(?:3rd|)\D+?)\s+(\d+)" \
				+ r"\s+(\S+)\s+(\D+(?:3rd|)\D+?)\s+(\d+)\s*(\S?\s*|Alphabet.*)",line)
			if (m2 is not None):
				word_n = remove_page(m2.group(3))
				wordlist[word_n] = m2.group(1)
				worddesc[word_n] = m2.group(2)

				word_n = remove_page(m2.group(6))
				wordlist[word_n] = m2.group(4)
				worddesc[word_n] = m2.group(5)


for i in range(6000):
	if (wordlist[i] is not None):
		print (f"{i}\t{wordlist[i]}\t{len(worddesc[i])}\t{worddesc[i]}")

for i in range(5000):
	if (wordlist[i] is None):
		print (i, " None")

for i in range(5001,6000):
	if (wordlist[i] is not None):
		print (i, wordlist[i])
