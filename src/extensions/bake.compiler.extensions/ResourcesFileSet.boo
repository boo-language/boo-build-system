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

namespace Bake.Compiler.Extensions

import System
import System.IO
import System.Globalization  
import System.Collections
import System.Text.RegularExpressions

import Bake.IO.Extensions

# This allows us to get the namespace for each resource
# if no namespace was defined, then we use the matching source file's 
# namespace/class or the directory structure. This match VS.Net behaviour
class ResourcesFileSet(FileSet):
	
	_nameSpacePatterns = {}
	
	_cultures as IList
	
	# This regex is used in PrepareResourceName() to 
	# replace all digits starting a namespace with _digit and convert any
	# non alphanumeric charcter to _
	_resNameCleanUpRegex = Regex("((?<=\\.)\\d)|([^\\d\\w])",RegexOptions.Compiled)
	
	[property(CodebehindExtentions)]
	_codebehindExtentions = (".aspx", ".asax", ".ascx", ".asmx")
	
	Cultures:
		get:
			if not _cultures:
				_cultures = []
				for culture in CultureInfo.GetCultures(CultureTypes.AllCultures):
					_cultures.Add(culture.Name)
			return _cultures
	
	def constructor():
		pass
		
	static def op_Implicit(patterns as Boo.Lang.List) as ResourcesFileSet:
		rfs = ResourcesFileSet()
		for pattern in patterns:
			rfs.Include(pattern)
		return rfs

	def Include(pattern as string, namespacePrefix as string):
		dummy = []
		Include(pattern)
		entry = AddRegEx(pattern,dummy)
		_nameSpacePatterns[entry] = namespacePrefix
		
	def GetResourceName(resourceName as string, compiler as CompilerBase) as string:
		namespacePrefix = GetNameSpacePrefix(resourceName)
		if namespacePrefix:
			return namespacePrefix + Path.GetFileName(resourceName)
		ext =  Path.GetExtension(resourceName).ToLower()
		resource, resourceName, ns, clazz = "","","",""
		source = compiler.FindSourceFileName(resourceName)
		culture = GetResourceCulture(resourceName,source)
		if ext == ".resx":
				resource = StripResourceCulture(resourceName,culture)
				source = compiler.FindSourceFileName(resource)
				if File.Exists(source):
					ns = compiler.GetFileNameSpace(source)
					clazz = compiler.GetFileClass(source)
				else:
					ns = GetResourceBaseDir(resourceName) 
					clazz = GetResourceFileName(resourceName)
				resourceName = ns + '.' + clazz
				resourceName += '.' + culture if culture.Length>0
		elif ext == ".resources":
			resourceName = GetResourceBaseDir(resourceName) + Path.GetFileName(resourceName)
		else:  
			# Special case for licenses.licx, put it in the root of the project
			# and give it a special name
			if "licenses.licx" == Path.GetFileName(resourceName).ToLower():
				resourceName = Path.GetFileName(compiler.OutputFileInfo.FullName) + ".licenses"
			else:
				resourceName = GetResourceBaseDir(resourceName)
				# Not sure why we are stripping the culture here, but that is the way NAnt is
				# doing it, so'll follow along for now.
				resourceName += StripResourceCulture(Path.GetFileName(resourceName),culture)
		return PrepareResourceName(resourceName)
	
	private def GetResourceFileName(resourceName as string) as string:
		resNoExt = Path.GetFileNameWithoutExtension(resourceName)
		resExt = Path.GetExtension(resourceName)                 
		# This handle the ASP.Net code behind files:
		# WebForm1.aspx.resx -> WebForms1
		for ext in CodebehindExtentions:
			if ext== resExt:
				resNoExt = Path.GetFileNameWithoutExtension(resNoExt)
				break
		return resNoExt
		
	private def PrepareResourceName(resourceName as string) as string:
		return _resNameCleanUpRegex.Replace(resourceName,"_\${digit}")
		
	private def GetNameSpacePrefix(path as string) as string:
		for entry as Entry in _nameSpacePatterns.Keys:
			if CheckPath(entry,path):
				return _nameSpacePatterns[entry]
		return null
	
	private def GetResourceBaseDir(resourceName as string) as string:
		baseDir = BaseDirectory
		baseDir += Path.DirectorySeparatorChar if baseDir.EndsWith(Path.DirectorySeparatorChar.ToString())
		resourceName += Path.DirectorySeparatorChar if resourceName.EndsWith(Path.DirectorySeparatorChar.ToString())
		return resourceName if baseDir == resourceName
		return resourceName.Substring(baseDir.Length)
		
	#TODO: Check that this works with the extention dot
	private def StripResourceCulture(resourceName as string, culture as string) as string:
		resNoExt = Path.GetFileNameWithoutExtension(resourceName)
		if resNoExt.EndsWith(culture):
			resNoExt = resNoExt.Substring(0,resNoExt.Length - culture.Length)
		return resNoExt + Path.GetExtension(resourceName)
		
	def GetResourceCulture(resourceName as string, sourceFile as string) as  string:
		resNoExt = Path.GetFileNameWithoutExtension(resourceName)
		# This handle the case of a source file that ends with a culture name
		# e.g. Foo.en-US.cs will have a non localized resource file named Foo.en-US.resx
		return "" if resNoExt==Path.GetFileNameWithoutExtension(sourceFile) and File.Exists(resourceName)
		index = resNoExt.LastIndexOf('.'[0])
		if index!=-1:
			cultureStr = resNoExt.Substring(index) 
			if Cultures.Contains(cultureStr):
				return cultureStr
		return ""


