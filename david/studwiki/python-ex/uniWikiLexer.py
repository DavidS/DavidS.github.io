#!/usr/bin/python

# (C) Copyright 2003 by David Schmitt

import re
import kjParser

class Lexer:
	"""implement lex interface for kjParser derived parsers
		This lexer recognizes and disambiguates Wiki idosyncrazinesses
	"""
	def setSource(self, source):
		if 'source' in dir(self) and self.source != None:
			self.source += source
		else:
			self.source = source
		self.compileSource()

	def DUMP(self):
		return "LL"

	def compileSource(self):
		# clean NUL
		self.source = re.sub("\000", "NUL", self.source)
		self.source = re.sub("\001", "ONE", self.source)
		self.source = re.sub("\n\s*\n", "\n\0EMPTYLINE\0\n", self.source)
		self.source = re.sub("\n", "\0NL\0", self.source)
		self.source = re.sub("\0+", "\0", self.source)
		self.source = re.sub("^\0+", "", self.source)
		self.source = re.sub("\0+$", "", self.source)
		if len(self.source) > 0:
			self.tokens = re.split("\0", self.source)
		else:
			self.tokens = ()
		

	def getmember(self):
		"""returns the current token on the stream"""
		if len(self.tokens) > 0:
			return self.tokens[0]
		else:
			return kjParser.ENDOFFILETERM
	
	def next(self):
		"""moves on to next token"""
		self.tokens = self.tokens[1:]
		
	def more(self):
		"""returns false if current token is the last token"""
		return len(self.tokens) > 0
	


if __name__ == "__main__":
	l = Lexer()
	source = """line1
line2
	
that was a empty line
"""
	#source = ""
	#source = "."
	l.setSource(source)
	while l.more():
		print l.getmember()
		l.next()
