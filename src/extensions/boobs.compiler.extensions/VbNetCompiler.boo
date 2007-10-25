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

namespace Boobs.Compiler.Extensions

import System
import System.IO
import System.Text.RegularExpressions
import System.CodeDom.Compiler
import System.Reflection
import Microsoft.CSharp

class Vbc(CompilerBase):
	 
	static classRE = Regex("class\\s+(?<class>@?[\\w_][\\w\\d_]+)",RegexOptions.Compiled)
	static namespaceRE = Regex("namespace\\s+(?<namespace>@?[\\w_][\\w\\d_\\.]+)",RegexOptions.Compiled)
	
	[property(Checked)]
	_checked as bool
	
	[property(BaseAdress)]
	_baseAddress as int = -1
	
	[property(DocFile)]
	_docFile as string  
	
	_docFileInfo as FileInfo
	DocFileInfo as FileInfo:
		get:
			_docFileInfo = GetFileInfo(DocFile,_docFileInfo)
			return _docFileInfo
	
	[property(NoStdLib)]
	_noStdLib as bool = false
	
	[property(NoConfig)]
	_noConfig as bool = false
	
	[property(Unsafe)]
	_unsafe as bool = false
	
	[property(Optimize)]
	_optimize as bool = false
	
	[property(Codepage)]
	_codepage as string
	
	[property(RootNamespace)]
	_rootNamespace as string
	
	_compiler as ICodeCompiler

	def constructor():
		super()

	def constructor(baseDir as string):
		super(baseDir)
		
	def Execute():
		if not _name or _name == string.Empty:
			Name = FindVbCompiler()
		super()
	
	private def FindVbCompiler() as string:
		return VbCompilerFinder().Find()
		
	override def WriteOptions():
		WriteOption("baseadress",BaseAdress.ToString()) if BaseAdress != -1
		WriteOption("doc",DocFileInfo.FullName) if DocFile
		if Debug:
			WriteOption("debug")
			WriteOption("define","DEBUG")
			WriteOption("define","TRACE")
		WriteOption("nostdlib") if NoStdLib
		WriteOption("checked") if Checked
		WriteOption("unsafe") if Unsafe
		WriteOption("optimize") if Optimize
		WriteOption("rootnamespace", RootNamespace) if RootNampspace
		WriteOption("codepage",Codepage) if Codepage
		Arguments.Add("/noconfig") if NoConfig
	
	override def NeedsCompiling():
		if DocFileInfo and not DocFileInfo.Exists:
			//logger.Debug("Doc file doesn't exist, recompiling.") if logger.IsDebugEnabled
			return true
		return super.NeedsCompiling()
		
	def GetFileNameSpace(path as string) as string:
		 return FindRegExInFile(path,classRE, "class")
		
	def GetFileClass(path as string) as string:
		return FindRegExInFile(path,namespaceRE, "namespace")
	
	override Extention as String:
		get:
			return "vb"

class VbCompilerFinder:

	def Find():
		if Boo.Lang.Useful.PlatformInformation.IsMono:
			return FindVbnc()
		else:
			return FindVbc()
			
	private def FindVbnc():
		dir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)
		path = Path.Combine(dir, "vbnc.exe")
		if File.Exists(path): return path
		return "vbnc" //try msc in PATH
			
	private def FindVbc():
		vbc = FindLocalVbc()
		if vbc: return vbc
		vbc = FindInFramework()
		if vbc: return vbc
		return "vbc" //try csc in PATH
		
	private def FindLocalVbc():
		dir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)
		path = Path.Combine(dir, "vbc.exe")
		if File.Exists(path): return path
		return null
		
	private def FindInFramework():
		asm = Assembly.Load("Boobs.Win32.Helper")
		fit as duck = asm.GetType("Boobs.Win32.Helper.FrameworkInformation")
		return Path.Combine(fit.Actual.FullPath, "vbc.exe")
