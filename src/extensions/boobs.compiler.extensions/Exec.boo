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
import System.Collections.Specialized
import System.Threading
import System.Diagnostics

class Exec:
	 	 
	_name as string
	_exePath as string
	_baseDir as string = Environment.CurrentDirectory
	
	BaseDirectory:
		get:
			return _baseDir
		set:
			OnBaseDirChanged(_baseDir,value)
			_baseDir = value
	
	[property(ExitCode)]
	_exitCode as int = 0
	
	[property(TimeOut)]
	_timeout as int = int.MaxValue
	
	[property(FailOnError)]
	_failOnError as bool = true
	
	[property(Arguments)]
	_args = StringCollection()
	
	_cmdLine as string
	virtual CommandLine as string:
		get:
			if not _cmdLine:
				return join(_args, ' ')
			return _cmdLine
	
	_stdOut as StreamReader
	_stdErr as StreamReader
	    
	def constructor(executable as string, commandLine as string):
    	self()
    	_exePath = executable
    	_cmdLine = commandLine
	
	def constructor():
		Reset()

	Name:
		get:
			if(not _name):
				_name = self.GetType().Name
			return _name
		set:
			_name = value

	virtual ExecutablePath:
		get:
			if(not _exePath):
				_exePath = Name
			return _exePath
		set:
			_exePath = value
	
	parent as Exec
	
	virtual Parent as Exec:
		get:
			return parent
		set:
			CopySettings(value)
			parent = value

	virtual def Execute():
		outputThread as Thread = null
		errorThread as Thread = null
		process as Process = null
		try:
			process = StartProcess()
			outputThread = Thread()do:
				Output(_stdOut,Console.Out)
			errorThread = Thread() do:
				Output(_stdErr,Console.Error)
			
			outputThread.Start()
			errorThread.Start()
			
			Wait(process,(outputThread,errorThread))
		
			ExitCode = process.ExitCode
			
			if(ExitCode != 0):
				raise BuildException("${ExecutablePath} failed with return code: ${ExitCode}")
		
		except e:
			if(FailOnError):
				raise
		ensure:
			outputThread.Abort() if outputThread and outputThread.IsAlive
			errorThread.Abort() if errorThread and errorThread.IsAlive
	
	virtual protected def Reset():
		ExitCode = 0
		
	private def StartProcess() as Process:
		process = Process()
		PrepareProcess(process)    
		process.Start()  
		_stdOut = process.StandardOutput
		_stdErr = process.StandardError
		return process
	
	virtual protected def PrepareProcess(process as Process):
		process.StartInfo.FileName = ExecutablePath
		process.StartInfo.Arguments = CommandLine
		process.StartInfo.RedirectStandardOutput = true
		process.StartInfo.RedirectStandardError = true
		process.StartInfo.UseShellExecute = false
		process.StartInfo.WorkingDirectory = BaseDirectory
	
	virtual protected def CopySettings(parent as Exec):
		BaseDirectory = parent.BaseDirectory
		FailOnError = parent.FailOnError
		TimeOut = parent.TimeOut

	private def Output(coming as TextReader, going as TextWriter):
		while(true):
			log = coming.ReadLine()
			if(not log):
				break
			going.WriteLine(log)
		going.Flush()
	
	private def Wait(process as Process, threads as (Thread)):
		process.WaitForExit(TimeOut)
		for thread in threads:
			thread.Join(500)
		if(not process.HasExited):
			try:
				process.Kill()
			except:
				pass # don't care about these exceptions
			raise ApplicationException("${ExecutablePath} did not finish in ${TimeOut} ms.")
	
	virtual protected def OnBaseDirChanged(oldDir as string, newDir as string):
		pass


