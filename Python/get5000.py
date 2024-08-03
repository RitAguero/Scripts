import re
import os.path
import configparser



class Get5000:

	def __init__(self, source_file):
		self.wordlist = [None] * 6000
		self.worddesc = [None] * 6000
		self.wordindex = {}
		self.source_file = source_file if source_file else "spanish5000.txt"

	def remove_page(self,word_id):
		if (len(word_id) > 4):
			return int(word_id[:-3])
		return int(word_id)

	def load(self) -> int:
		if (not os.path.isfile(self.source_file)):
			print(f"Couldn't load the 5000 dictionary. File not found: {source_file}")
			return -1

		with open(self.source_file) as f:
			for line in f:
				line = line.strip()
				m1 = re.fullmatch(r"(\S+)\s+(\D+(?:3rd|)\D+?)\s+(\d+)\s*(\s*|Alphabet.*)",line)
				if (m1 is not None):
					word_n = self.remove_page(m1.group(3))
					self.wordlist[word_n] = m1.group(1)
					self.worddesc[word_n] = m1.group(2)
					self.wordindex[m1.group(1)] = word_n
				else:
					m2 = re.fullmatch(r"(\S+)\s+(\D+(?:3rd|)\D+?)\s+(\d+)" \
						+ r"\s+(\S+)\s+(\D+(?:3rd|)\D+?)\s+(\d+)\s*(\S?\s*|Alphabet.*)",line)
					if (m2 is not None):
						word_n = self.remove_page(m2.group(3))
						self.wordlist[word_n] = m2.group(1)
						self.wordindex[m2.group(1)] = word_n
						self.worddesc[word_n] = m2.group(2)

						word_n = self.remove_page(m2.group(6))
						self.wordlist[word_n] = m2.group(4)
						self.wordindex[m2.group(4)] = word_n
						self.worddesc[word_n] = m2.group(5)
		return 0

	def print_info(self) -> None:
		none_diag = ''
		extra_diag = ''

		for i in range(6000):
			word = self.wordlist[i]

			if (word is not None):
				desc = self.worddesc[i]
				print (f"{i}\t\"{word}\"\t{len(desc)}\t{desc}")
				if (i>5000):
					extra_diag += f"{i}\t{word}\t{desc}\n"
			elif (i<5001):
				none_diag += f"{i} None\n"

		print (f"{none_diag}{extra_diag}")



class Get1M:
	def __init__(self, source_file):
		self.source_file = source_file
		self.wordlist = [None]*50000
		self.wordcount = [None]*50000

	def load(self) -> int:
		if (not os.path.isfile(self.source_file)):
			print(f"Couldn't load the 1M database. File not found: {self.source_file}")
			return -1

		with open(self.source_file) as f:
			for line in f:
				line_parts = line.split("\t")
				if (len(line_parts) > 2):
					try: 
						word_n = int(line_parts[0])
						if (word_n < 100):
							continue
						self.wordlist[word_n-100] = line_parts[1]
						self.wordcount[word_n-100] = int(line_parts[2])
						if (word_n > 20100):
							break
					except Exception as ex:
						print (f"While parsing entry: {line}\n\twas an error:{ex}")
		return 0

	def print_info(self, ref_dic) -> None:
		for i in range(20000):
			if (self.wordlist[i] is not None):
				ext_num = ''
				if (ref_dic is not None):
					if (self.wordlist[i] in ref_dic.wordindex):
						ext_num = ref_dic.wordindex[self.wordlist[i]]
				print (f"{i}#{ext_num}({self.wordcount[i]}): \"{self.wordlist[i]}\"")





def main():
	config = configparser.ConfigParser()
	words_db = ''
	try:
	    config_file = os.path.join(os.path.dirname(__file__),'get5000.ini')
	    config.read_file(open(config_file))
	    words_db = config.get('data','WordsDB',fallback='')
	    print(words_db)
	except Exception as ex:
	    print (f"Couldn't get configuration: {ex}")

	base5000 = Get5000(None)
	if (base5000.load() == 0):
		base5000.print_info()

	print ('W',words_db)

	words_databases = []
	for file in words_db.split('\n'):
		print (f"loading {file}")
		arg_database = Get1M(file.strip())
		if (arg_database.load() == 0):
			arg_database.print_info(base5000)
			words_databases.append(arg_database)



if (__name__ == "__main__"):
	main() 