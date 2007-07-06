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

