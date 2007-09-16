namespace Boobs.Win32.Helper

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
