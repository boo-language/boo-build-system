#region license
# Copyright (c) 2007, Georges Benatti Jr
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Georges Benatti Jr nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

#############################################################################
# Based on Class from NUncle by "Ayende Rahien"

namespace Bake.Compiler.Extensions

import System
import System.IO

abstract class BuildBase(Exec):
	
	protected _responseFile as string
	protected _optionsWriter as StreamWriter
	
	# The output file for the build
	[property(OutputFile)]
	_outFile as string

	# The target for the build
	[property(OutputTarget)]
	_outTarget as TargetType = TargetType.Exe
	
	# The icon for the build
	[property(Win32Icon)]
	_win32Icon as string
	
	_win32IconInfo as FileInfo
	Win32IconInfo as FileInfo:
		get:
			_win32IconInfo = GetFileInfo(Win32Icon, _win32IconInfo)
			return _win32IconInfo

	# Build anyway, regardless of the timestamps
	[property(ForceBuild)]
	_forceBuild as bool	 
	
	# Print even more info
	[property(Verbose)]
	_verbose as bool = false
	
	# Resources
	[property(ResourcesSet)]
	_resources = ResourcesFileSet()
	
	_outputInfo as FileInfo
	OutputFileInfo as FileInfo:
		get:
			_outputInfo = GetFileInfo(OutputFile, _outputInfo)
			return _outputInfo 
			
	
	override CommandLine as string:
		get:
			return "@\""+_responseFile+"\" " + join(Arguments," ")
	
	protected def constructor():
		pass
	
	protected def constructor(baseDir as string):
		BaseDirectory = baseDir
		
	protected def OpenOptionsWriter() as StreamWriter:
		_responseFile = Path.GetTempFileName()
		_optionsWriter = StreamWriter(_responseFile)
		return _optionsWriter
	
	protected def CloseOptionsWriter():
		if _optionsWriter:
			_optionsWriter.Close()
			_optionsWriter = null
	
	protected def CleanUp():
		CloseOptionsWriter()
		File.Delete(_responseFile)
		
	virtual protected def WriteOption(option as string):
		out = "/${option}"
		_optionsWriter.WriteLine(out)
		if Verbose:
			print out
		
	virtual protected def WriteOption(option as string, val as string):
		out = "/${option}:${val}"
		_optionsWriter.WriteLine(out)
		if Verbose:
			print out
	
	virtual protected def WriteOptions():
		pass
	
	protected def GetFileInfo(file as string, fileInfo as FileInfo) as FileInfo:
		if not file: return null
		if not fileInfo or fileInfo.Name != Path.GetFileName(OutputFile):
			return FileInfo(OutputFile)
		return fileInfo
	
	protected def FindRegExInFile(path as string, RegEx as regex, group as string) as string:
		if not File.Exists(path): return ""
		using sr = StreamReader(path):
			while (line = sr.ReadLine())!=null:
				match = RegEx.Match(line)
				if match.Success:
					return match.Groups[group].Value
		return ""
	
	protected override def OnBaseDirChanged(oldDir as string, newDir as string):
		super.OnBaseDirChanged(oldDir, newDir)
		ResourcesSet.BaseDirectory = newDir
		
	def Resources(pattern as string):
		ResourcesSet.Include(pattern)

