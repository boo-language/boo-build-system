#region license
# Copyright (c) 2007, Georges Benatti Jr
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Georges Benatti Jr nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Bake.Win32.Helper

import System
import System.Collections.Generic
import System.IO

import Microsoft.Win32

class FrameworkInformation:

#region static members
	
	static Installed as List of FrameworkInformation:
		get:
			LazyLoadInformation()
			return _installed
			
	static _installed = List of FrameworkInformation()

	static Actual as FrameworkInformation:
		get:
			LazyLoadInformation()
			return _actual
			
	static _actual as FrameworkInformation

	static private def LazyLoadInformation():
		installPath = GetDotNetInstallPath()
		if installPath:
			fullPath = Path.Combine(installPath, FormatVersion())
			_actual = FrameworkInformation(fullPath)
			_installed.Add(_actual)

	static private def GetDotNetInstallPath():
		regKey = Registry.LocalMachine.OpenSubKey("SOFTWARE\\Microsoft\\.NETFramework\\")
		if regKey:
			installRoot = regKey.GetValue("installRoot", "").ToString()
			regKey.Close()
		
		return installRoot

	static private def FormatVersion():
		version = Environment.Version
		return "v${version.Major}.${version.Minor}.${version.Build}"

#endregion

	[getter(FullPath)]
	_fullPath as string

	def constructor(fullPath as string):
		_fullPath = fullPath
