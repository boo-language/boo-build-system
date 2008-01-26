namespace Bake.Engine

import System
import System.Collections

class CircularDepenendcyException(Exception):
"""Description of CircularDepenendcyException"""
	def constructor(targets as IList, current as Task):
		super(BuildMessage(targets, current))

	private def BuildMessage(targets as IList, current as Task):
		msg = "Circular dependency detected:\n"
		for target as Task in targets:
			msg += "    Target: ${target.Name}\r\n"
		msg += " >> Target: ${current.Name} <- circular dependency"
		return msg
