<#
.SYNOPSIS
Install the specified dotfile(s)

.DESCRIPTION
The install.ps1 script installs the PowerShell and/or vim dotfiles.

.PARAMETER InstallComponents
Specify the component(s) to be installed.

.INPUTS
None. You cannot pipe objects to install.ps1

.OUTPUTS
None. Install.ps1 does not generate any output

.NOTES
Copyright (C) 2014 by Richard Abbenhuis

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without l> imitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

Revisions:
14-11-2014  R. Abbenhuis    Created install.ps1
#>

param (
    [Parameter(Mandatory = $false,
        Position = 0)]
    [String[]] $InstallComponents = "all"
) # param

[String] $Script:InstallPath = $MyInvocation.MyCommand.Path
[String] $Script:DotFilesPath = Split-Path $Script:InstallPath

<#
.SYNOPSIS
Confirm overwrite if destination exists.

.DESCRIPTION
This function will check if the path exists. If it exists the user
will be asked if it should be overwritten.

.PARAMETER Path
The path to be checked.

.INPUTS
None. You cannot pipe objects to CanInstall.

.OUTPUTS
System.Boolean. CanInstall returns a boolean confirming if the
installation can be continued.

.NOTES
Revisions:
14-11-2014  R. Abbenhuis    Created CanInstall
#>
function script:CanInstall {
    param (
        [Parameter(Mandatory = $true,
                   Position = 0)]
        [String] $Path
    ) # param

    if (Test-Path $Path) {
        # The path already exists, so ask the user if the
        # installation should overwrite the path.
        #
        [String] $Private:UserAnswer = Read-Host "$Path already exists. Overwrite it? [Y/n]"

        if ($Private:UserAnswer.ToUpper() -eq "N") {
            return $false
        } # if ($Private:UserAnswer.ToUpper() -eq "N")
    } # if (Test-Path $Path)

    return $true
} # function script:CanInstall

<#
.SYNOPSIS
Copy the dotfile

.DESCRIPTION
Copy the dotfile from the given source to the specified destination

.PARAMETER Source
The source of the dotfile.

.PARAMETER Destination
The destination of the dotfile.

.INPUTS
None. You cannot pipe objects to CopyDotFile.

.OUTPUTS
None. CopyDotFile does not generate any output.

.NOTES
Revisions:
14-11-2014  R. Abbenhuis    Created CopyDotFile
#>
function CopyDotFile {
    param (
        [Parameter(Mandatory = $true,
                   Position = 0)]
        [String] $Source,

        [Parameter(Mandatory = $true,
                   Position = 1)]
        [String] $Destination
    ) # param

    if (CanInstall $Destination) {
        Write-Host "Install dotfile $source to $destination"

        if (Test-Path $Destination) {
            # The destination already exists, so delete
            # it first.
            #
            Remove-Item $Destination -Recurse
        } # if (Test-Path $Destination)

        Copy-Item $Source $Destination -Recurse
    } # if (CanInstall $Destination)
} # function CopyDotFile

<#
.SYNOPSIS
Install vim dotfiles.

.DESCRIPTION
Copy the $HOME\dotfiles\vim and all it's subdirectories to $HOME\.vim.
After copying the files vimrc and gvimrc are moved to $HOME\_vimrc and
$HOME\_gvimrc. After that it will move
$HOME\.vim\bundle\pathogen\autoload\pathogen.vim to $HOME\.vim\autoload
and then delete the directory $HOME\.vim\bundle\pathogen

.INPUTS
None. You cannot pipe objects to InstallVimFiles.

.OUTPUTS
None. InstallVimFiles does not generate any output.

.NOTES
Revisions:
14-11-2014  R. Abbenhuis    Created InstallVimFiles
#>
function Script:InstallVimFiles {
    [String] $Private:SourcePath = Join-Path $Script:DotFilesPath "vim"
    [String] $Private:DestinationPath = Join-Path $HOME ".vim"
    [String] $Private:SourceFile = ""
    [String] $Private:DestinationFile = ""
    [String] $Private:PathogenSourcePath = Join-Path $HOME ".vim\bundle\pathogen"

    # Copy the vim dotfiles
    #
    CopyDotFile $Private:SourcePath $Private:DestinationPath

    # Move the vimrc file.
    #
    $Private:SourceFile = Join-Path $Private:DestinationPath "vimrc"
    $Private:DestinationFile = Join-Path $HOME "_vimrc"
    Move-Item $Private:SourceFile $Private:DestinationFile -Force

    # Move the gvimrc file.
    #
    $Private:SourceFile = Join-Path $Private:DestinationPath "gvimrc"
    $Private:DestinationFile = Join-Path $HOME "_gvimrc"
    Move-Item $Private:SourceFile $Private:DestinationFile -Force

    # Install pathogen
    #
    New-Item -Path $Private:DestinationPath -Name "autoload" -ItemType Directory
    $Private:SourceFile = Join-Path $Private:PathogenSourcePath "autoload\pathogen.vim"
    $Private:DestinationFile = Join-Path $HOME ".vim\autoload\pathogen.vim"
    Move-Item $Private:SourceFile $Private:DestinationFile -Force
    Remove-Item $Private:PathogenSourcePath -Recurse -Force

    # Add other directories
    #
    New-Item -Path $Private:DestinationPath -Name "after" -ItemType Directory
} # function Script:InstallVimFiles

# Get the components to be installed
#
foreach($Component in $InstallComponents.Split(',')) {
    switch ($Component) {
        "all" {
            InstallVimFiles
            break
        } # all
        "vim" {
            InstallVimFiles
        } # vim
        "powershell" {
        } # powershell
    } # switch ($Component)
} #foreach($Component in $InstallComponents.Split(','))

