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

import System
import System.Runtime.InteropServices

#############################################################################
# Based on Class from NUncle by "Ayende Rahien"

import Boobs.IO.Extensions

# This class will also resolve references to assemblies in the framework
# directory (allowing to do things like Include("System.Windows.Forms.dll") 
# and spesificed directories.

class AssemblyFileSet(FileSet):
	
	[property(Lib)]
	_lib as FileSet
	
	override BaseDirectory:
		set:
			super.BaseDirectory = value
			_lib.BaseDirectory = value
	
	def constructor():
		_lib = FileSet()

	override def Scan():
		super.Scan()
		ResolveReferences()
		
	static def op_Implicit(patterns as Boo.Lang.List) as AssemblyFileSet:
		afs = AssemblyFileSet()
		for pattern in patterns:
			afs.Include(pattern)
		return afs

	private def ResolveReferences():
		for directory in Lib.Directories:
			# We don't do a recursive scan because that has been handled
			# in Lib already, and all the recursiveness has been explired
			ScanDir(directory, false)
		ScanDir(RuntimeEnvironment.GetRuntimeDirectory(), false)

