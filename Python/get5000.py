import re
import os.path
import configparser

SUFFIX_VOWELS = ('','a','e','o','á','é','ó','i','í','u','ú')
UNSTRESSED_VOWELS = ('a','e','o','u','i')


class WordInfo:
	def __init__(self,word,word_n,word_count):
		self.word = word.lower()
		self.word_n = word_n
		self.word_count = int(word_count)
		self.plural_forms = []
		self.other_forms = []
		self.info = f"[{word} {word_count.strip()}]"

	def add_count(self,add_count,word):
		self.word_count += int(add_count)
		self.add_info([word,add_count.strip()])

	def add_form(self,word_form,count,form_kind = 0):
		if (form_kind == 0):
			self.other_forms.append(word_form)
			self.add_info(["Other:",word_form,str(count).strip()])
		else:
			self.plural_forms.append(word_form)
			self.add_info([word_form,str(count).strip()])


	def add_info(self,info):
		self.info += f",[{' '.join(info)}]"


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
		self.wordlist = [None]*2000000
		self.wordcount = [None]*2000000
		self.word_database = {}

	def load(self) -> int:
		if (not os.path.isfile(self.source_file)):
			print(f"Couldn't load the 1M database. File not found: {self.source_file}")
			return -1

		with open(self.source_file) as f:
			# dict per words, case-ins
			for line in f:
				line_parts = line.split("\t")
				if (len(line_parts) > 2):
					try: 
						word_n = int(line_parts[0])
						if (word_n < 100):
							continue

						word = line_parts[1]
						word_count = line_parts[2]
						if (word.lower() in self.word_database):
							self.word_database[word.lower()].add_count(word_count,word)
							# now element should be repositioned
							# new_position_max = self.word_database[word.lower()].word_n
							# new_position_min = 1
						else:
							self.word_database[word.lower()] = WordInfo(word.lower(),word_n-100,word_count)



						self.wordlist[word_n-100] = line_parts[1]
						self.wordcount[word_n-100] = int(line_parts[2])
						# if (word_n > 20100):
						# 	break
					except Exception as ex:
						print (f"While parsing entry: {line}\n\twas an error:{ex}")


		# checks variants: word + s/as/es/os/ás... ; word - s/as/es...
		# rules: after unstressed vowels - plurals: += 's'
		#        after others except 'é'            += 'es'
		for word in self.word_database:
			for vowel in SUFFIX_VOWELS:
				form_kind = 0
				if (word[-1] in UNSTRESSED_VOWELS):
					if (vowel == ''):
						form_kind = 1
				elif (word[-1] != 'é'):
					if (vowel == 'e'):
						form_kind = 1
				self.check_variant(word,word + vowel + 's',form_kind)

			if (len(word) > 1 and word.endswith('s')):
				form_kind = 1 if ( word[-2] in UNSTRESSED_VOWELS ) else 0				
				self.check_variant(word,word[:-1],form_kind)
				if (word[-2] in SUFFIX_VOWELS):
					form_kind = 0
					if (len(word) > 2 and word[-2]=='e' and\
						(word[-3] not in UNSTRESSED_VOWELS) and\
						(word[-3] != 'é')\
						):
						form_kind = 1
					self.check_variant(word,word[:-2],form_kind)

		return 0


	def check_variant(self,word,variant,form_kind=0):
		if (variant in self.word_database):
			self.word_database[word].add_form(variant,\
				str(self.word_database[variant].word_count), form_kind)


	def print_info(self, ref_dic) -> None:
		for word in self.word_database:
			other_forms = self.word_database[word].other_forms
			if (len(other_forms) > 0):
				print (f"{word} {other_forms}")

		print ("====================================================================")
		# for i in range(1000):
		# 	if (self.wordlist[i] is not None):
		# 		ext_num = ''
		# 		if (ref_dic is not None):
		# 			if (self.wordlist[i] in ref_dic.wordindex):
		# 				ext_num = ref_dic.wordindex[self.wordlist[i]]
		# 		print (f"{i}#{ext_num}({self.wordcount[i]}): \"{self.wordlist[i]}\"")

		# wcnt = 0
		# for word in self.word_database.values():
		# 	if (not(word.word is str)):
		# 		print (word,str(word.word))
		# 	if (not(word.word_count is int)):
		# 		print ("Count not int:",word.word,word.word_count)
		# 	wcnt+=1
		# 	if (wcnt > 1000):
		# 		break

		sorted_info = sorted(self.word_database.values(),key=lambda k:(-k.word_count, k.word))
		of_count = 1
		for w in sorted_info:
			# print ('\t'.join([w.word,str(w.word_count),str(w.plural_forms),w.info]))
			if (len(w.other_forms) > 0):
				print (of_count,'.',w.word,'\t',str(w.other_forms), w.word_count, str(w.info))
				of_count += 1




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