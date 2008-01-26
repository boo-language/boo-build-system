namespace Bake.Engine

import System
import System.Collections

class Configuration(IQuackFu):
	options as IDictionary
	
	def constructor(options as IDictionary):
		self.options = options
	
	public def QuackGet(name as string, parameters as (object)) as object:
		raise "Could not find configuration option ${name}!" unless options.Contains(name)
		return options[name]
	
	public def QuackSet(name as string, parameters as (object), value as object) as object:
		raise NotImplementedException()
	
	public def QuackInvoke(name as string, *args as (object)) as object:
		raise NotImplementedException()

