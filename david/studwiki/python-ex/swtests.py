#!/usr/bin/python

# (C) Copyright 2003 by David Schmitt

import unittest
import uniWikiParser
import uniWikiLexer
# from uniWikiLexer import Lexer
import os

class SetupCorrectTests(unittest.TestCase):
	def testInputExists(self):
		assert os.path.exists("../input.sw"), "input.sw missing"
	
	def testInputIsFile(self):
		assert os.path.isfile("../input.sw"), "input.sw not a file"

class TestLexer(unittest.TestCase):
	def setUp(self):
		self.lexer = uniWikiLexer.Lexer()
		self.lexer.setSource("")

	def testBuilding(self):
		assert self.lexer != None, "lexer could not be built"

	def testNullLexer(self):
		assert not self.lexer.more(), "lexer has not recognized empty string"

	def testDotLexerStart(self):
		self.lexer.setSource(".")
		assert self.lexer.more, "error on start"

	def testDotLexer(self):
		self.testDotLexerStart()
		assert self.lexer.getmember() == ".", "lexer has not recognized '.'"

	def testDotLexerFinish(self):
		self.testDotLexer()
		self.lexer.next()
		assert not self.lexer.more(), "error at end"

class TestParser(unittest.TestCase):
	def setUp(self):
		self.parser = uniWikiParser.build()

	def testBuilding(self):
		assert self.parser != None, "parser could not be built"

	def testNullParse(self):
		assert self.parser.DoParse(""), "parser has not recognized empty string"

	def testDotParse(self):
		print `self.parser.DFA.StateTokenMap`
		assert self.parser.DoParse("dot"), "parser has not recognized 'dot'"

if __name__ == "__main__":
	unittest.main()

