namespace Boobs

import System

import Boo.Lang.Useful.CommandLine

class BoobsCommandLine(AbstractCommandLine):
"""Description of BoobsCommandLine"""

	[Option("Use given buildfile", LongForm: "file", ShortForm: "f")]
	public File as string

	[Option("Run specified target", LongForm: "target", ShortForm: "t")]
	public Target as string

	[Option("Print this message", LongForm: "help", ShortForm: "h")]
	public Help as bool
	
	public Options = {}
	
	[Option("Options passed to the build script in the -o:foo=bar format", ShortForm: "o", MaxOccurs: int.MaxValue)]
	def Option([required] option as string):
		index = option.IndexOf("=")
		if index == -1:
			raise CommandLineException("Invalid option ${option} - should be key:value")
		Options[ option.Substring(0, index) ] = option.Substring(index+1)

