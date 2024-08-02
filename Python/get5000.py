import re



class Get5000:

	def __init__(self, source_file):
		self.wordlist = [None] * 6000
		self.worddesc = [None] * 6000
		self.source_file = source_file if source_file else "spanish5000.txt"

	def remove_page(self,word_id):
		if (len(word_id) > 4):
			return int(word_id[:-3])
		return int(word_id)

	def load(self):
		with open(self.source_file) as f:
			for line in f:
				line = line.strip()
				m1 = re.fullmatch(r"(\S+)\s+(\D+(?:3rd|)\D+?)\s+(\d+)\s*(\s*|Alphabet.*)",line)
				if (m1 is not None):
					word_n = self.remove_page(m1.group(3))
					self.wordlist[word_n] = m1.group(1)
					self.worddesc[word_n] = m1.group(2)
				else:
					m2 = re.fullmatch(r"(\S+)\s+(\D+(?:3rd|)\D+?)\s+(\d+)" \
						+ r"\s+(\S+)\s+(\D+(?:3rd|)\D+?)\s+(\d+)\s*(\S?\s*|Alphabet.*)",line)
					if (m2 is not None):
						word_n = self.remove_page(m2.group(3))
						self.wordlist[word_n] = m2.group(1)
						self.worddesc[word_n] = m2.group(2)

						word_n = self.remove_page(m2.group(6))
						self.wordlist[word_n] = m2.group(4)
						self.worddesc[word_n] = m2.group(5)


def main():
	base5000 = Get5000(None)
	base5000.load()

	none_diag = ''
	extra_diag = ''

	for i in range(6000):
		word = base5000.wordlist[i]

		if (word is not None):
			desc = base5000.worddesc[i]
			print (f"{i}\t{word}\t{len(desc)}\t{desc}")
			if (i>5000):
				extra_diag += f"{i}\t{word}\t{desc}\n"
		elif (i<5001):
			none_diag += f"{i} None\n"

	print (f"{none_diag}{extra_diag}")


if (__name__ == "__main__"):
	main() 