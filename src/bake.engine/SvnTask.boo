namespace Bake.Engine

import System
import System.Xml

class SvnTask(Task):
	_pathToSvn as string
	_workingCopyPath as string
	
	def constructor([required] name as string, pathToSvn as string, workingCopyPath as string):
		super(name)
		_pathToSvn = pathToSvn
		_workingCopyPath = workingCopyPath

	def ShouldRun() as bool:
		lastUpdate = GetLastUpdate()
		currentWorkingCopyDate = date.Parse(lastUpdate)
		LogDebug "Last update of SVN ${lastUpdate}"
		info = SvnHelper.ExecuteAndReturnXml(_pathToSvn,"log --non-interactive --xml -r {${lastUpdate}} ${_workingCopyPath}")
		for node as XmlNode in info.SelectNodes("/log/logentry/date"):
			if date.Parse(node.InnerText) > currentWorkingCopyDate:
				LogDebug "Found log entry at ${node.InnerText} that is more recent than ${lastUpdate}"
				return true 
		LogDebug "Could not find a log entry after ${lastUpdate}, skipping ${Name}"
		return false
	
	private def GetLastUpdate():
		info = SvnHelper.ExecuteAndReturnXml(_pathToSvn,"info --non-interactive --xml ${_workingCopyPath}")
		return info.SelectSingleNode("/info/entry/commit/date").InnerText
