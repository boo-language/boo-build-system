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
import System.Collections
import System.Collections.Specialized

import Boobs.IO.Extensions

abstract class CompilerBase(BuildBase):
	
	_tmpResources as IList
	_cultures as Hashtable           

	protected def constructor():
		Reset()
	
	protected def constructor(baseDir as string):
		super(baseDir)
		Reset()
			
	# Generate debug build
	[property(Debug)]
	_debug as bool = false

	# Space seperate string of the symbols to define	
	[property(Define)]
	_define as string
	
	# Threat warnings as erors
	[property(WarnAsError)]
	_warnasError as bool
	
	# The warnings to ignore
	[property(SupressWarnings)]
	_supressWarnings = StringCollection()
	
	# Whatever the compiler support supressing errors
	[property(SupportSupressingWarnings)]
	_supportSupressingWarnings as bool = false
	
	# Which type contains the Main method that you want to use if you've
	# severals that have psv Main()
	# Correspond to the /m[ain]:type flag
	[property(MainType)]
	_mainType as string
	
	# References
	[property(ReferencesSet)]
	_references = AssemblyFileSet()
	
	# Modules
	[property(ModulesSet)]
	_modules = FileSet()
	
	# Sources to compile
	[property(SourcesSet)]
	_sources = FileSet()
	
	virtual def FindSourceFileName(resourceFile as string) as string:
		return Path.ChangeExtension(resourceFile,Extention)
		
	abstract def GetFileNameSpace(path as string) as string:
		pass
		
	abstract def GetFileClass(path as string) as string:
		pass
	
	abstract Extention as String:
		get:
			pass
	
	override def Execute():
		if not NeedsCompiling():
			return
		# This will clean up the task if the same object is run more than once
		Reset()
		
		# Scan explicity, not really needed, but I want to be clear what is going
		# on. May take a while time if there are lots of files and complex patterns
		SourcesSet.Scan()
		ReferencesSet.Scan()
		ModulesSet.Scan()
		
//		logger.Debug("Compiling ${SourcesSet.Files.Count} files to ${OutputFileInfo.FullName}") if logger.IsDebugEnabled
		
		try:
			using super.OpenOptionsWriter():
				# Allows derived classes to add options
				WriteOptions()
				WriteCommonOptions()
				
				for reference in ReferencesSet.Files:
					WriteOption("reference", reference)
				for module in ModulesSet.Files:
					WriteOption("addmodule", module)
				WriteResources()
				WriteSources()
				
				CloseOptionsWriter()
				# This will call the compiler and compile everything
				super.Execute()
				
				CreateSatelliteAssemblies()
		ensure:
			CleanUp()

	virtual protected def WriteCommonOptions():
		WriteOption("nologo")
		WriteOption("target", OutputTarget.ToString().ToLower())
		WriteOption("define", Define) if Define
		WriteOption("out", OutputFileInfo.FullName)
		WriteOption("win32icon", Win32IconInfo.FullName) if Win32Icon
		WriteOption("main", MainType) if MainType
		WriteOption("warnaserror","") if WarnAsError	 
	
		if SupressWarnings.Count>0:
			if _supportSupressingWarnings:
				WriteOption("nowarn",join(SupressWarnings,", "))
			else:
				pass
				// logger.Debug("${Name} doesn't support supressing warnings.") if logger.IsDebugEnabled
		
	
	private def CreateSatelliteAssemblies():
		for culture in _cultures.Keys:
			culturedir = Path.Combine(OutputFileInfo.DirectoryName,culture)
			Directory.CreateDirectory(culturedir)
			outFile = Path.Combine(culturedir,Path.GetFileNameWithoutExtension(OutputFileInfo.Name)+".resources.dll")
			al = AssemblyLinker(BaseDirectory)
			al.Parent = self
			al.OutputFile = outFile
			cultureResources = _cultures[culture] as Hashtable
			for name in cultureResources.Keys:
				al.ResourcesSet.Include(cultureResources[name],name);
			// logger.Debug("Creating satallite assembly ${outFile} for culture ${culture}.") if logger.IsDebugEnabled
			al.Execute()
			
	protected def WriteResources():
		for resource in ResourcesSet.Files:
			if Path.GetExtension(resource).ToLower() == ".resx":
				resource = CompileResource(resource)
				_tmpResources.Add(resource)
			resourceName = ResourcesSet.GetResourceName(resource,self)
			culture = ResourcesSet.GetResourceCulture(resource,FindSourceFileName(resource))
			if culture.Length > 0:
				_cultures.Add(culture, {}) if not _cultures.ContainsKey(culture)
				# This stores the culturized resource in a hash table under the spesific
				# culture. The culture's hashtable contain the resource name and filename
				# so we can later use them to created sattalite assemblies
				cast(Hashtable, _cultures[culture])[resourceName] = resource
			WriteOption("resource","${resource},${resourceName}")
			
	private def WriteSources():
		for file in SourcesSet.Files:
			_optionsWriter.WriteLine("\""+file+"\"")
		
	private def CompileResource(resx as string) as string:
		resource = Path.ChangeExtension(resx,".resources")
		resgen = Exec("ResGen", "/compile ${resx},${resource}")
		resgen.Parent = self
		resgen.Execute()
		
	protected def CleanUp():
		super.CleanUp()
		if _tmpResources:
			for resource in _tmpResources:
				File.Delete(resource)
		
	override protected def Reset():
		_cultures = {}
		_tmpResources = []
		_responseFile = null
		
	virtual protected def NeedsCompiling():
		if OutputFileInfo is null:
			return false
			
		if ForceBuild:
//			logger.Debug("ForceBuild set to true, rebuilding.") if logger.IsDebugEnabled
			return true
			
		if OutputFileInfo and not OutputFileInfo.Exists:
//			logger.Debug("File doesn't exist, buildng.") if logger.IsDebugEnabled
			return true
			
		if SourcesSet.ContainFileMoreRecentThan(OutputFileInfo.LastWriteTime) or \
			ReferencesSet.ContainFileMoreRecentThan(OutputFileInfo.LastWriteTime) or \
			ModulesSet.ContainFileMoreRecentThan(OutputFileInfo.LastWriteTime) or \
			ResourcesSet.ContainFileMoreRecentThan(OutputFileInfo.LastWriteTime):
//				logger.Debug("Sources, Modules, References or Resources has been updated, compiling.") if logger.IsDebugEnabled
				return true
				
		if Win32Icon and Win32IconInfo.LastWriteTime > OutputFileInfo.LastWriteTime:
			return true
			
		return false

	protected override def OnBaseDirChanged(oldDir as string, newDir as string):
		super.OnBaseDirChanged(oldDir,newDir)
		ModulesSet.BaseDirectory = newDir
		ReferencesSet.BaseDirectory = newDir
		SourcesSet.BaseDirectory = newDir

	def Sources(pattern as string):
		SourcesSet.Include(pattern)
		
	def Modules(pattern as string):
		ModulesSet.Include(pattern)
	
	def References(pattern as string):
		ReferencesSet.Include(pattern)
		
	def CompileTo(file as string):
		OutputFile = file
		Execute()





