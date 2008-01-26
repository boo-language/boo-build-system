#region license
# Copyright (c) 2006, Georges Benatti Jr
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Georges Benatti Jr nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Boobs.IO.Extensions

import System
import System.Collections.Generic
import System.IO

def Exist(name as string):
	exist = File.Exists(name)
	exist = Directory.Exists(name) if not exist
	return exist

def Cp(source as string, target as string):
	File.Copy(source, target)
	
def Cp(source as string, target as string, overwrite as bool):
	File.Copy(source, target, overwrite)

def Cp(sources as FileSet, targetDir as string):
	for source in sources.Files:
		target = Path.Combine(targetDir, Path.GetFileName(source))
		File.Copy(source, target)

def Cp(sources as FileSet, targetDir as string, overwrite as bool):
	for source in sources.Files:
		target = Path.Combine(targetDir, Path.GetFileName(source))
		File.Copy(source, target, overwrite)

def Mv(source as string, target as string):
	File.Move(source, target)
	
def Rm(filename as string):
	File.Delete(filename)
	
def Rm(dirname as string, pattern as string):
	for fname in Directory.GetFiles(dirname, pattern):
		File.Delete(fname)

def Rm(sources as FileSet):
	for fname in sources.Files:
		File.Delete(fname)

def MkDir(path as string):
	Directory.CreateDirectory(path)

def RmDir(dirname as string):
	Directory.Delete(dirname)
	
def RmDir(path as string, recursive as bool):
	Directory.Delete(path, recursive)

def IsUpToDate(target as string, source as string):
	return true unless File.Exists(source)
	return false unless File.Exists(target)

	targetInfo = FileInfo(target)
	sourceInfo = FileInfo(source)

	return targetInfo.LastAccessTimeUtc >= sourceInfo.LastAccessTimeUtc

def IsUpToDate(target as string, sources as FileSet):
	for source in sources.Files:
		if not IsUpToDate(target, source): return false
	
	return true
