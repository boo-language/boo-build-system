#region license
# Copyright (c) 2006, Georges Benatti Jr
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Georges Benatti Jr nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Boobs.Engine.Builder

import System
import Boobs.Engine
	
class BoobsBaseScript:
	static defaultSvnPath = """c:\Program Files\Subversion\bin\svn.exe"""

	[getter(Engine)]
	_engine = BoobsEngine()
	
	def Task(name as string, dependencies as List):
		_engine.AddTask(name, dependencies)
		
	def Task(name as string, block as TaskBlock):
		_engine.AddTask(name, block)

	def Task(name as string, dependencies as List, block as TaskBlock):
		_engine.AddTask(name, dependencies, block)

	def File(name as string, dependencies as List):
		_engine.AddFileTask(name, dependencies)

	def File(name as string, block as TaskBlock):
		_engine.AddFileTask(name, block)

	def File(name as string, dependencies as List, block as TaskBlock):
		_engine.AddFileTask(name, dependencies, block)
		
	def Svn(name as string, pathToSvn as string, workingCopyPath as string, dependecies as List, block as TaskBlock):
		_engine.AddSvnTask(name , pathToSvn, workingCopyPath, dependecies, block)
		
	def Svn(name as string, pathToSvn as string, workingCopyPath as string, block as TaskBlock):
		_engine.AddSvnTask(name , pathToSvn, workingCopyPath, [], block)
 
	def Svn(name as string, workingCopyPath as string, dependecies as List, block as TaskBlock):
		Svn(name, defaultSvnPath, workingCopyPath, dependecies, block)

	def Svn(name as string, workingCopyPath as string, block as TaskBlock):
		Svn(name, defaultSvnPath, workingCopyPath, [], block)

	def Svn(name as string, dependecies as List, block as TaskBlock):
		Svn(name, defaultSvnPath, Environment.CurrentDirectory, dependecies, block)
	
	def Svn(name as string, block as TaskBlock):
		Svn(name, [], block)

	def Desc(description as string):
		_engine.SetDescription(description)
	
	def Execute(target as string):
		_engine.Execute(target)
	
	def SvnUpdate(pathToSvn as string, workingCopyPath as string):
		print SvnHelper.Execute(pathToSvn, "update ${workingCopyPath} --non-interactive")
 
	def SvnUpdate(workingCopyPath as string):
		SvnUpdate(defaultSvnPath, workingCopyPath)

	def SvnUpdate():
		SvnUpdate(defaultSvnPath, Environment.CurrentDirectory)
