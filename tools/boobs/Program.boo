#region license
# Copyright (c) 2006, Georges Benatti Jr
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Georges Benatti Jr nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Boobs

import System
import System.Collections
import System.IO
import System.Reflection

import Boo.Lang.Useful.CommandLine

import Boobs.Engine
import Boobs.Engine.Builder

class Program:
	
	_cmdLine = BoobsCommandLine()

	def PrintGreetings():
		print "Boo Build System - version 0.2\n"

	def ProcessOptions(args as (string)):
		try:
			_cmdLine.Parse(args)
		except x as CommandLineException:
			error = x

		if error is not null or _cmdLine.Help:
			print error.Message if error is not null
			Usage()
			return false
			
		return true

	def Usage():
		print "Usage: Boobs [options]"
		print "Options: "
		_cmdLine.PrintOptions()
		print "\nThe file 'boobsfile' will be used if no buildfile is specified.\n"

	def Process():
		filename = GetFileName()
	
		if not File.Exists(filename):
			print "Could not find '${filename}'\n"
			return false
		
		print "Running buildfile: ${filename}\n"
	
		return ExecuteScript(filename)
		
	def GetFileName():
		if _cmdLine.File:
			filename = Path.Combine(Environment.CurrentDirectory, _cmdLine.File)
		else:
			filename = Path.Combine(Environment.CurrentDirectory, "boobsfile")
		return filename		

	def ExecuteScript(filename as string):
		try:
			using f = File.OpenText(filename):
				builder = BoobsEngineBuilder(f)
				engine = builder.Build()
				if engine:
					engine.RunTask += do(task as Task):
						if task.Description.Length: 
							print "${task.Description}:\n"
						else:
							print "${task.Name}:\n"
					
					if _cmdLine.Target:
						engine.Execute(_cmdLine.Target)
					else:
						engine.Execute()
				else:
					print builder.Errors.ToString()
		except ex:
			print ex.Message
			return false
	
		return true
	
	def Main(args as (string)):
		PrintGreetings()
		if ProcessOptions(args):
			if Process(): return 0
		return -1

[STAThread]
def Main(argv as (string)):
	return Program().Main(argv)
