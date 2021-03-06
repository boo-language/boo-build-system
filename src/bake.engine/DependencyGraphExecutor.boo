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

class DependencyGraphExecutor:
"""Description of DependencyGraphExecutor"""

	event RunTask as RunTaskHandler

	_tasks as List
	_target as string
	_currentlyExecuting = []
	
	def constructor(tasks as List, target as string):
		_tasks = tasks
		_target = target

	def Execute():
		t, h = PrepareToRun()
		ExecuteTask(t, h)
		
	private def PrepareToRun():
		h = BuildTasksHash()
		t = h[_target] as Task
		raise TargetNotFoundException(_target) unless t
		return t, h
		
	def Analize(block as callable(Task, Hash)):
		t, h = PrepareToRun()
		block(t, h)

	private def BuildTasksHash():
		temp = {}
		for t as Task in _tasks:
			temp[t.Name] = t
			
		return temp

	private def ExecuteTask(t as Task, h as Hash):
		return if not t or t.Executed 
		
		if _currentlyExecuting.Contains(t):
			raise CircularDepenendcyException(_currentlyExecuting, t) 
		
		_currentlyExecuting.AddUnique(t)
		
		RunTask(t)
		
		for childName as string in t.Dependencies:
			ExecuteTask(h[childName] as Task, h) 
		
		if t.ShouldRun() and t.Block: t.Block(t)

		t.Executed = true
		_currentlyExecuting.Remove(t)
