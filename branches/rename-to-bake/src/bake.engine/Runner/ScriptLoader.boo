#region license
# Copyright (c) 2006, Georges Benatti Junior
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Andrew Davey nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Bake.Engine.Runner

import System
import System.IO
import System.Reflection

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.IO
import Boo.Lang.Compiler.Pipelines
import Boo.Lang.Compiler.Steps

internal class CreateRunnerStep(AbstractCompilerStep):
	_baseTypeName as string
	
	def constructor():
		pass
	
	def constructor(baseTypeName as string):
		_baseTypeName = baseTypeName
	
	override def Run():
		module = CompileUnit.Modules[0]
		
		method = Method(Name: "Execute",
						Body: module.Globals)
						
		module.Globals = Block()
		
		loader = ClassDefinition(Name: "__Runner__")
		loader.BaseTypes.Add(SimpleTypeReference(_baseTypeName))
		loader.Members.Add(method)
		
		for member in module.Members:
			loader.Members.Add(member)
		
		module.Members.Clear()
		module.Members.Add(loader)

class ScriptLoader:
"""Description of ScriptLoader"""

	[getter(GeneratedType)]
	_type as Type

	[getter(Result)]
	_result as CompilerContext

	[getter(References)]
	_references = AssemblyCollection()
	
	[property(BaseTypeName)]
	_baseTypeName as string
	
	Errors as CompilerErrorCollection:
		get:
			return _result.Errors
	
	def Load([required] reader as StreamReader) as bool:
		code = reader.ReadToEnd()
		result = CompileScript(code)
		return ProcessResult(result)
		
	private def CompileScript(code as string) as CompilerContext:
		compiler = BooCompiler()
		compiler.Parameters.Ducky = true
		compiler.Parameters.Pipeline = CompileToMemory()
		compiler.Parameters.Input.Add(StringInput("<code>", code))
		compiler.Parameters.OutputType = CompilerOutputType.Library
		
		for reference as Assembly in _references:
			compiler.Parameters.References.Add(reference)

		pipeline = compiler.Parameters.Pipeline
		pipeline.Insert(1, CreateRunnerStep(_baseTypeName))
		return compiler.Run()		

	protected def ProcessResult(result as CompilerContext):
		_result = result
		
		if len(result.Errors) == 0:
			_type = _result.GeneratedAssembly.GetType("__Runner__")
			
		return len(result.Errors) == 0

