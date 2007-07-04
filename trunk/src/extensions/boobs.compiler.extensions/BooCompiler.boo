#region license
# Copyright (c) 2007, Georges Benatti Jr
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Georges Benatti Jr nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Boobs.Compiler.Extensions

import System.IO
import System.Reflection
import System.Text.RegularExpressions

class Booc(CompilerBase):
	private static _classNameRegex = Regex('^((?<comment>/\\*.*?(\\*/|$))|[\\s\\.\\{]+|class\\s+(?<class>\\w+)|(?<keyword>\\w+))*')
	private static _namespaceRegex = Regex('^((?<comment>/\\*.*?(\\*/|$))|[\\s\\.\\{]+|namespace\\s+(?<namespace>(\\w+(\\.\\w+)*)+)|(?<keyword>\\w+))*')

	[property(NoConfig)]	
	private _noconfig = false
	
	[property(NoStdLib)]
	private _nostdlib = false
	
	[property(WhiteSpaceAgnostic)]
	private _wsa = false
	
	[property(Ducky)]
	private _ducky = false

	[property(Pipeline)]
	private _pipeline as string

	def Execute():
		if not _name or _name == string.Empty:
			Name = FindBooc()
		super()

	private def FindBooc() as string:
		dir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)
		path = Path.Combine(dir, "booc.exe")
		if File.Exists(path): return path
		return "booc" //try booc in PATH

	protected def WriteCommonOptions():
		WriteOption("target", OutputTarget.ToString().ToLower())
		WriteOption("out", OutputFileInfo.FullName)

	protected def WriteOptions():
		if Debug:
			WriteOption('debug')
		else:
			WriteOption('debug-')
		if NoConfig:
			WriteOption('noconfig')
		if NoStdLib:
			WriteOption("nostdlib")
		if Verbose:
			WriteOption("vv")
		if WhiteSpaceAgnostic:
			WriteOption("wsa")
		if Ducky:
			WriteOption("ducky")
		if Pipeline:
			WriteOption("p", _pipeline)
	
	protected def WriteOption(name as string):
		_optionsWriter.WriteLine("-{0}", name)
		
	protected def WriteOption(name as string, value as string):
		if name == "resource": name = "embedres"
		
		if " " in value and not IsQuoted(value):
			_optionsWriter.WriteLine("-{0}:\"{1}\"", name, value)
		else:
			_optionsWriter.WriteLine("-{0}:{1}", name, value)
			
	def IsQuoted(value as string):
		return value.StartsWith("\"") and value.EndsWith("\"")

	def GetFileNameSpace(path as string) as string:
		 return FindRegExInFile(path, _classNameRegex, "class")
		
	def GetFileClass(path as string) as string:
		return FindRegExInFile(path, _namespaceRegex, "namespace")
	
	override Extention as string:
		get:
			return "boo"

