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

class AssemblyLinker(BuildBase):
	
	# This should be a culture string according to
	# RFC 1766
	[property(Culture)]
	_culture as string
	
	[property(TemplateFile)]
	_templateFile as string
	
	_templateFileInfo as FileInfo
	TemplateFileInfo as FileInfo:
		get:
			_templateFileInfo = GetFileInfo(TemplateFile, _templateFileInfo)
			return _templateFileInfo
	
	[property(KeyFile)]
	_keyFile as string
	
	_keyFileInfo as FileInfo
	KeyFileInfo:
		get:
			_keyFileInfo = GetFileInfo(KeyFile, _keyFileInfo)
			return _keyFileInfo
	
	def constructor():
		super()

	def constructor(baseDir as string):
		super(baseDir)
	
	override ExecutablePath:
		get:
			return "al.exe"
	
	override def Execute():
//		if not NeedsCompiling():
//			return

		_responseFile = Path.GetTempFileName()
		
		try:
			
			using super.OpenOptionsWriter():
				//logger.Debug("Compiling ${ResourcesSet.Files.Count} file(s) to ${OutputFileInfo.FullName}") if logger.IsDebugEnabled
				
				WriteOption("nologo")
				WriteOption("target",OutputTarget.ToString())
				WriteOption("out",OutputFileInfo.FullName)
				WriteOption("culture",Culture) if Culture
				WriteOption("template",TemplateFileInfo.FullName) if TemplateFileInfo
				WriteOption("keyfile",KeyFileInfo.FullName) if KeyFileInfo
				
				for resource in ResourcesSet.Files:
					WriteOption("embed",resource)
				
				CloseOptionsWriter()
				
				# Do the real work
				super.Execute()
		ensure:
			CleanUp()
	
	def NeedsCompiling() as bool:
		if ForceBuild:
			return true
		raise NotImplementedException()

	protected def CleanUp():
		super.CleanUp()


