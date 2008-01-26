namespace Boobs.Engine

import System
import System.Diagnostics
import System.Xml
import System.IO

class SvnHelper:
	static def ExecuteAndReturnXml(pathToSvn as string, parameters as string):
		output = Execute(pathToSvn, parameters)
		info = XmlDocument()
		info.Load( StringReader(output) )
		return info
		
	static def Execute(pathToSvn as string, parameters as string):
		psi = ProcessStartInfo(pathToSvn,
			parameters,
			RedirectStandardOutput: true,
			UseShellExecute: false)
		
		LogDebug "Executing ${pathToSvn} ${parameters}"
		
		svn = Process(StartInfo: psi)
		svn.Start()
		svn.WaitForExit()
		
		if svn.ExitCode != 0:
			raise InvalidOperationException("Could not get the results of ${pathToSvn} ${parameters}")
			
		return svn.StandardOutput.ReadToEnd()

	static def LogDebug(msg as string):
		print "Debug: ${msg}"
	
	static def LogWarn(msg as string):
		print "Warn: ${msg}"
		
	static def LogError(msg as string):
		print "Error: ${msg}"
