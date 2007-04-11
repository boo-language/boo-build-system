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
import System.IO
import System.Reflection

import Boo.Lang.Compiler

import Boobs.Engine
import Boobs.Engine.Runner

class BoobsEngineBuilder:
"""Description of BoobsEngineBuilder"""
	_reader as StreamReader
	_loader as ScriptLoader
	_genObj as duck
	
	[getter(References)]
	_references = AssemblyCollection()

	Errors as CompilerErrorCollection:
		get:
			return _loader.Errors

	def constructor(reader as StreamReader):
		_reader = reader
		
	def Build() as BoobsEngine:
		if BuildAndRunLoader():
			baseObj = cast(BoobsBaseScript, _genObj)
			return baseObj.Engine
		else:
			return null
		
	protected def BuildAndRunLoader():
		if BuildLoader():
			return RunGeneratedCode()
		return false

	protected def BuildLoader():
		try:
			_loader = ScriptLoader()
			_loader.BaseTypeName = "Boobs.Engine.Builder.BoobsBaseScript"
			AddReferences()
			return _loader.Load(_reader)
		except x:
			raise LoadBoobsScriptException("Load BoobsScript Error", x)

	protected def AddReferences():
		_loader.References.Add(typeof(BoobsBaseScript).Assembly)
		for reference as Assembly in _references:
			_loader.References.Add(reference)
			
	protected def RunGeneratedCode():
		try:
			genType = _loader.GeneratedType
			_genObj = genType()
			_genObj.Execute()
			return true
		except x:
			raise CompileBoobsScriptException("Compile BoobsScript Error", x)
