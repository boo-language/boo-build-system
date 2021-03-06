#region license
# Copyright (c) 2006, Georges Benatti Jr
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Georges Benatti Jr nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Bake.Engine

import System
import System.Collections

class BakeEngine:
"""Description of BakeEngine."""

	event RunTask as RunTaskHandler

	_tasks = []
	_description = ""
		
	def constructor():
		pass
		
	def Execute():
		UnifyTasks()
		ValidateGraph()
		ExecuteDependencyGraph()
		
	def Execute(target as string):
		UnifyTasks()
		ValidateGraph(target)
		ExecuteDependencyGraph(target)

	def AddTask(name as string, dependencies as List):
		_tasks.Add(Task(name, Description: ConsumeDescription(), Dependencies: dependencies))
		
	def AddTask(name as string, block as TaskBlock):
		_tasks.Add(Task(name, Description: ConsumeDescription(), Block: block))

	def AddTask(name as string, dependencies as List, block as TaskBlock):
		_tasks.Add(Task(name, Description: ConsumeDescription(), Dependencies: dependencies, Block: block))

	def AddFileTask(name as string, dependencies as List):
		_tasks.Add(FileTask(name, Description: ConsumeDescription(), Dependencies: dependencies))

	def AddFileTask(name as string, block as TaskBlock):
		_tasks.Add(FileTask(name, Description: ConsumeDescription(), Block: block))

	def AddFileTask(name as string, dependencies as List, block as TaskBlock):
		_tasks.Add(FileTask(name, Description: ConsumeDescription(), Dependencies: dependencies, Block: block))

	def AddSvnTask(name as string, pathToSvn as string, workingCopyPath as string, dependencies as IList, block as TaskBlock):
		svnTask = SvnTask(name, pathToSvn, workingCopyPath, 
			Description: ConsumeDescription(), 
			Dependencies: dependencies,
			Block: block)
		_tasks.Add(svnTask)

	def SetDescription(description as string):
		_description = description
		
	protected def ConsumeDescription():
		actualDesciption = _description
		_description = ""
		return actualDesciption
		
	protected def UnifyTasks():
		temp = {}
		
		for task as Task in _tasks:
			if temp[task.Name]:
				t = temp[task.Name] as Task
				t.Merge(task)
			else:
				temp[task.Name] = task
			
		_tasks = List(temp.Values)
		
	protected def ValidateGraph():
		ValidateGraph("default")
		
	protected def ValidateGraph(target as string):				
		dgx = DependencyGraphExecutor(_tasks, target)
		dgx.Analize(ExistTask)

	protected def ExistTask(task as Task, hash as Hash):
		if not task: raise TargetNotFoundException(task.Name)

		for childName in task.Dependencies:
			if not hash.Contains(childName): 
				raise DependencyNotFoundException(childName)
			ExistTask(hash[childName], hash)
		
	protected def ExecuteDependencyGraph():
		ExecuteDependencyGraph("default")
		
	protected def ExecuteDependencyGraph(target as string):
		dgx = DependencyGraphExecutor(_tasks, target)
		dgx.RunTask += { task as Task | RunTask(task) }
		dgx.Execute()


