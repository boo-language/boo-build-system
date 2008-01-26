namespace Bake.Tests

import System

import NUnit.Framework
import Bake.Compiler.Extensions
import Bake.IO.Extensions

[TestFixture]
class BoocFixture:
"""Description of BoocFixture"""
	
	[Test]
	def BoocNotConfiguredShouldRun():
		compiler = Booc()
		compiler.Execute()
		
	[Test]	
	def SimpleCompilation():
		compiler = Booc()
		compiler.SourcesSet = FileSet("*.boo")
		compiler.OutputFile = "output.exe"
		compiler.Execute()

