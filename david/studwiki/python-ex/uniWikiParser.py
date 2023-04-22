#!/usr/bin/python

# (C) Copyright 2003 by David Schmitt

import uniWikiLexer
import kjParser
import kjParseBuild

def echo(vals):
	print vals

class WikiParser(kjParseBuild.CGrammar):
	def __init__(self):
		kjParseBuild.CGrammar.__init__(self, None, None, None, {})
		self.lexer = uniWikiLexer.Lexer()

	def DoParse(self, string, context = None):
		self.lexer.setSource(string)
		Stack = [] # {-1:0} #Walkers.SimpleStack()
		parseOb = kjParser.ParserObj( self.RuleL, self.lexer, self.DFA, Stack, \
			1, context )
		# do the parse
		parseResult = parseOb.GO()
		# return final result of reduction and the context
		return (parseResult, context)

def build():
	"""builds the parser for the wiki input"""
	# build grammar with custom lexer
	result = WikiParser()
	#result = kjParseBuild.NullCGrammar()
	result.SetCaseSensitivity(0)
	result.Nonterms("Document Empty")
	result.Addterm('dot', 'dot', echo)
	result.Declarerules("""
		Document ::
			@R EmptyRule :: Document >>
			@R DotRule :: Document >> dot
	""")
	result.Compile()
	return result

