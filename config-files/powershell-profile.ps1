using namespace System.Management.Automation
using namespace System.Management.Automation.Language

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host $stopwatch.Elapsed "alias"

New-Alias grep findstr -Force
New-Alias which Get-Command -Force
New-Alias pn pnpm -Force
New-Alias p pnpm -Force

Write-Host $stopwatch.Elapsed "alias done"

if ((Test-Path -Path Function:\InstallModuleIfNotInstalled)) { 
  Remove-Item Function:\InstallModuleIfNotInstalled 
}
function InstallModuleIfNotInstalled {
  param (
    [string] $Name,
    [switch] $Import
  )
  
  if ((Get-Module -ListAvailable -Name $Name).Count -eq 0) {
    Write-Host "Installing $Name module..."
    Install-Module -Name $Name -Repository PSGallery -Force
  }
  
  if ($import) {
    Import-Module -Name $Name
  }
}

Write-Host $stopwatch.Elapsed "import 1"

InstallModuleIfNotInstalled -Name "Terminal-Icons" -Import

Write-Host $stopwatch.Elapsed "import 2"

InstallModuleIfNotInstalled -Name "PSReadLine"

Write-Host $stopwatch.Elapsed "import 3"

InstallModuleIfNotInstalled -Name "DockerCompletion" -Import

Write-Host $stopwatch.Elapsed "import 4"

InstallModuleIfNotInstalled -Name "posh-git" -Import # for git command completions

Write-Host $stopwatch.Elapsed "remove function InstallModuleIfNotInstalled"

# Remove-Item Function:\InstallModuleIfNotInstalled

Write-Host $stopwatch.Elapsed "init omp"
oh-my-posh init pwsh | Invoke-Expression

Write-Host $stopwatch.Elapsed "winget autocomplete"
# winget autocomplete
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
  [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
  $Local:word = $wordToComplete.Replace('"', '""')
  $Local:ast = $commandAst.ToString().Replace('"', '""')
  winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

Write-Host $stopwatch.Elapsed "dotnet autocomplete"
# dotnet cli autocomplete https://learn.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
  param($commandName, $wordToComplete, $cursorPosition)
  dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

Write-Host $stopwatch.Elapsed "task autocomplete"
# task autocomplete https://github.com/go-task/task/blob/main/completion/ps/task.ps1
Register-ArgumentCompleter -CommandName task -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

  if ($commandName.StartsWith('-')) {
    $completions = @(
      [CompletionResult]::new('--list-all ', '--list-all ', [CompletionResultType]::ParameterName, 'list all tasks'),
      [CompletionResult]::new('--color ', '--color', [CompletionResultType]::ParameterName, '--color'),
      [CompletionResult]::new('--concurrency=', '--concurrency=', [CompletionResultType]::ParameterName, 'concurrency'),
      [CompletionResult]::new('--interval=', '--interval=', [CompletionResultType]::ParameterName, 'interval'),
      [CompletionResult]::new('--output=interleaved ', '--output=interleaved', [CompletionResultType]::ParameterName, '--output='),
      [CompletionResult]::new('--output=group ', '--output=group', [CompletionResultType]::ParameterName, '--output='),
      [CompletionResult]::new('--output=prefixed ', '--output=prefixed', [CompletionResultType]::ParameterName, '--output='),
      [CompletionResult]::new('--dry ', '--dry', [CompletionResultType]::ParameterName, '--dry'),
      [CompletionResult]::new('--force ', '--force', [CompletionResultType]::ParameterName, '--force'),
      [CompletionResult]::new('--parallel ', '--parallel', [CompletionResultType]::ParameterName, '--parallel'),
      [CompletionResult]::new('--silent ', '--silent', [CompletionResultType]::ParameterName, '--silent'),
      [CompletionResult]::new('--status ', '--status', [CompletionResultType]::ParameterName, '--status'),
      [CompletionResult]::new('--verbose ', '--verbose', [CompletionResultType]::ParameterName, '--verbose'),
      [CompletionResult]::new('--watch ', '--watch', [CompletionResultType]::ParameterName, '--watch')
    )

    return $completions.Where{ $_.CompletionText.StartsWith($commandName) }
  }

  return $(task --list-all --silent) | Where-Object { $_.StartsWith($commandName) } | ForEach-Object { return $_ + " " }
}

# az autocomplete
Register-ArgumentCompleter -Native -CommandName az -ScriptBlock {
  param($commandName, $wordToComplete, $cursorPosition)
  $completion_file = New-TemporaryFile
  $env:ARGCOMPLETE_USE_TEMPFILES = 1
  $env:_ARGCOMPLETE_STDOUT_FILENAME = $completion_file
  $env:COMP_LINE = $wordToComplete
  $env:COMP_POINT = $cursorPosition
  $env:_ARGCOMPLETE = 1
  $env:_ARGCOMPLETE_SUPPRESS_SPACE = 0
  $env:_ARGCOMPLETE_IFS = "`n"
  $env:_ARGCOMPLETE_SHELL = 'powershell'
  az 2>&1 | Out-Null
  Get-Content $completion_file | Sort-Object | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
  }
  Remove-Item $completion_file, Env:\_ARGCOMPLETE_STDOUT_FILENAME, Env:\ARGCOMPLETE_USE_TEMPFILES, Env:\COMP_LINE, Env:\COMP_POINT, Env:\_ARGCOMPLETE, Env:\_ARGCOMPLETE_SUPPRESS_SPACE, Env:\_ARGCOMPLETE_IFS, Env:\_ARGCOMPLETE_SHELL
}

Write-Host $stopwatch.Elapsed "set psreadline options"
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

# Searching for commands with up/down arrow is really handy.  The
# option "moves to end" is useful if you want the cursor at the end
# of the line while cycling through history like it does w/o searching,
# without that option, the cursor will remain at the position it was
# when you used up arrow, which can be useful if you forget the exact
# string you started the search on.
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Write-Host $stopwatch.Elapsed "set psreadline options done"
Write-Host $stopwatch.Elapsed "set linekeyhandler 1"
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Write-Host $stopwatch.Elapsed "set linekeyhandler 2"
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# This key handler shows the entire or filtered history using Out-GridView. The
# typed text is used as the substring pattern for filtering. A selected command
# is inserted to the command line without invoking. Multiple command selection
# is supported, e.g. selected by Ctrl + Click.
Write-Host $stopwatch.Elapsed "set linekeyhandler 3"
Set-PSReadLineKeyHandler -Key F7 `
  -BriefDescription History `
  -LongDescription 'Show command history' `
  -ScriptBlock {
  $pattern = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
  if ($pattern) {
    $pattern = [regex]::Escape($pattern)
  }

  $history = [System.Collections.ArrayList]@(
    $last = ''
    $lines = ''
    foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath)) {
      if ($line.EndsWith('`')) {
        $line = $line.Substring(0, $line.Length - 1)
        $lines = if ($lines) {
          "$lines`n$line"
        }
        else {
          $line
        }
        continue
      }

      if ($lines) {
        $line = "$lines`n$line"
        $lines = ''
      }

      if (($line -cne $last) -and (!$pattern -or ($line -match $pattern))) {
        $last = $line
        $line
      }
    }
  )
  $history.Reverse()

  $command = $history | Out-GridView -Title History -PassThru
  if ($command) {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
  }
}

# The built-in word movement uses character delimiters, but token based word
# movement is also very useful - these are the bindings you'd use if you
# prefer the token based movements bound to the normal emacs word movement
# key bindings.
Write-Host $stopwatch.Elapsed "set linekeyhandler 4"
Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellBackwardKillWord
Write-Host $stopwatch.Elapsed "set linekeyhandler 5"
Set-PSReadLineKeyHandler -Key Alt+b -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+f -Function ShellForwardWord
Write-Host $stopwatch.Elapsed "set linekeyhandler 6"
Set-PSReadLineKeyHandler -Key Alt+B -Function SelectShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+F -Function SelectShellForwardWord

#region Smart Insert/Delete

# The next four key handlers are designed to make entering matched quotes
# parens, and braces a nicer experience.  I'd like to include functions
# in the module that do this, but this implementation still isn't as smart
# as ReSharper, so I'm just providing it as a sample.

Write-Host $stopwatch.Elapsed "set linekeyhandler 7"
Set-PSReadLineKeyHandler -Key '"', "'" `
  -BriefDescription SmartInsertQuote `
  -LongDescription "Insert paired quotes if not already on a quote" `
  -ScriptBlock {
  param($key, $arg)

  $quote = $key.KeyChar

  $selectionStart = $null
  $selectionLength = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  # If text is selected, just quote it without any smarts
  if ($selectionStart -ne -1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $quote + $line.SubString($selectionStart, $selectionLength) + $quote)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    return
  }

  $ast = $null
  $tokens = $null
  $parseErrors = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)

  function FindToken {
    param($tokens, $cursor)

    foreach ($token in $tokens) {
      if ($cursor -lt $token.Extent.StartOffset) { continue }
      if ($cursor -lt $token.Extent.EndOffset) {
        $result = $token
        $token = $token -as [StringExpandableToken]
        if ($token) {
          $nested = FindToken $token.NestedTokens $cursor
          if ($nested) { $result = $nested }
        }

        return $result
      }
    }
    return $null
  }

  $token = FindToken $tokens $cursor

  # If we're on or inside a **quoted** string token (so not generic), we need to be smarter
  if ($token -is [StringToken] -and $token.Kind -ne [TokenKind]::Generic) {
    # If we're at the start of the string, assume we're inserting a new string
    if ($token.Extent.StartOffset -eq $cursor) {
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
      return
    }

    # If we're at the end of the string, move over the closing quote if present.
    if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
      return
    }
  }

  if ($null -eq $token -or
    $token.Kind -eq [TokenKind]::RParen -or $token.Kind -eq [TokenKind]::RCurly -or $token.Kind -eq [TokenKind]::RBracket) {
    if ($line[0..$cursor].Where{ $_ -eq $quote }.Count % 2 -eq 1) {
      # Odd number of quotes before the cursor, insert a single quote
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
    }
    else {
      # Insert matching quotes, move cursor to be in between the quotes
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    return
  }

  # If cursor is at the start of a token, enclose it in quotes.
  if ($token.Extent.StartOffset -eq $cursor) {
    if ($token.Kind -eq [TokenKind]::Generic -or $token.Kind -eq [TokenKind]::Identifier -or 
      $token.Kind -eq [TokenKind]::Variable -or $token.TokenFlags.hasFlag([TokenFlags]::Keyword)) {
      $end = $token.Extent.EndOffset
      $len = $end - $cursor
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len, $quote + $line.SubString($cursor, $len) + $quote)
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
      return
    }
  }

  # We failed to be smart, so just insert a single quote
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
}

Write-Host $stopwatch.Elapsed "set linekeyhandler 8"
Set-PSReadLineKeyHandler -Key '(', '{', '[' `
  -BriefDescription InsertPairedBraces `
  -LongDescription "Insert matching braces" `
  -ScriptBlock {
  param($key, $arg)

  $closeChar = switch ($key.KeyChar) {
    <#case#> '(' { [char]')'; break }
    <#case#> '{' { [char]'}'; break }
    <#case#> '[' { [char]']'; break }
  }

  $selectionStart = $null
  $selectionLength = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    
  if ($selectionStart -ne -1) {
    # Text is selected, wrap it in brackets
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $key.KeyChar + $line.SubString($selectionStart, $selectionLength) + $closeChar)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
  }
  else {
    # No text is selected, insert a pair
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
  }
}

Write-Host $stopwatch.Elapsed "set linekeyhandler 9"
Set-PSReadLineKeyHandler -Key ')', ']', '}' `
  -BriefDescription SmartCloseBraces `
  -LongDescription "Insert closing brace or skip" `
  -ScriptBlock {
  param($key, $arg)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  if ($line[$cursor] -eq $key.KeyChar) {
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
  }
  else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
  }
}

Set-PSReadLineKeyHandler -Key Backspace `
  -BriefDescription SmartBackspace `
  -LongDescription "Delete previous character or matching quotes/parens/braces" `
  -ScriptBlock {
  param($key, $arg)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  if ($cursor -gt 0) {
    $toMatch = $null
    if ($cursor -lt $line.Length) {
      switch ($line[$cursor]) {
        <#case#> '"' { $toMatch = '"'; break }
        <#case#> "'" { $toMatch = "'"; break }
        <#case#> ')' { $toMatch = '('; break }
        <#case#> ']' { $toMatch = '['; break }
        <#case#> '}' { $toMatch = '{'; break }
      }
    }

    if ($toMatch -ne $null -and $line[$cursor - 1] -eq $toMatch) {
      [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
    }
    else {
      [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
    }
  }
}

#endregion Smart Insert/Delete

# Sometimes you want to get a property of invoke a member on what you've entered so far
# but you need parens to do that.  This binding will help by putting parens around the current selection,
# or if nothing is selected, the whole line.
Write-Host $stopwatch.Elapsed "set linekeyhandler 10"
Set-PSReadLineKeyHandler -Key 'Alt+(' `
  -BriefDescription ParenthesizeSelection `
  -LongDescription "Put parenthesis around the selection or entire line and move the cursor to after the closing parenthesis" `
  -ScriptBlock {
  param($key, $arg)

  $selectionStart = $null
  $selectionLength = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  if ($selectionStart -ne -1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '(' + $line.SubString($selectionStart, $selectionLength) + ')')
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
  }
  else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
    [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
  }
}


# under or before the cursor.  It will cycle through single quotes, double quotes, or
# no quotes each time it is invoked.
Write-Host $stopwatch.Elapsed "set linekeyhandler 11"
Set-PSReadLineKeyHandler -Key "Alt+'" `
  -BriefDescription ToggleQuoteArgument `
  -LongDescription "Toggle quotes on the argument under the cursor" `
  -ScriptBlock {
  param($key, $arg)

  $ast = $null
  $tokens = $null
  $errors = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

  $tokenToChange = $null
  foreach ($token in $tokens) {
    $extent = $token.Extent
    if ($extent.StartOffset -le $cursor -and $extent.EndOffset -ge $cursor) {
      $tokenToChange = $token

      # If the cursor is at the end (it's really 1 past the end) of the previous token,
      # we only want to change the previous token if there is no token under the cursor
      if ($extent.EndOffset -eq $cursor -and $foreach.MoveNext()) {
        $nextToken = $foreach.Current
        if ($nextToken.Extent.StartOffset -eq $cursor) {
          $tokenToChange = $nextToken
        }
      }
      break
    }
  }

  if ($tokenToChange -ne $null) {
    $extent = $tokenToChange.Extent
    $tokenText = $extent.Text
    if ($tokenText[0] -eq '"' -and $tokenText[-1] -eq '"') {
      # Switch to no quotes
      $replacement = $tokenText.Substring(1, $tokenText.Length - 2)
    }
    elseif ($tokenText[0] -eq "'" -and $tokenText[-1] -eq "'") {
      # Switch to double quotes
      $replacement = '"' + $tokenText.Substring(1, $tokenText.Length - 2) + '"'
    }
    else {
      # Add single quotes
      $replacement = "'" + $tokenText + "'"
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
      $extent.StartOffset,
      $tokenText.Length,
      $replacement)
  }
}

# This example will replace any aliases on the command line with the resolved commands.
Write-Host $stopwatch.Elapsed "set linekeyhandler 12"
Set-PSReadLineKeyHandler -Key "Alt+%" `
  -BriefDescription ExpandAliases `
  -LongDescription "Replace all aliases with the full command" `
  -ScriptBlock {
  param($key, $arg)

  $ast = $null
  $tokens = $null
  $errors = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

  $startAdjustment = 0
  foreach ($token in $tokens) {
    if ($token.TokenFlags -band [TokenFlags]::CommandName) {
      $alias = $ExecutionContext.InvokeCommand.GetCommand($token.Extent.Text, 'Alias')
      if ($alias -ne $null) {
        $resolvedCommand = $alias.ResolvedCommandName
        if ($resolvedCommand -ne $null) {
          $extent = $token.Extent
          $length = $extent.EndOffset - $extent.StartOffset
          [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
            $extent.StartOffset + $startAdjustment,
            $length,
            $resolvedCommand)

          # Our copy of the tokens won't have been updated, so we need to
          # adjust by the difference in length
          $startAdjustment += ($resolvedCommand.Length - $length)
        }
      }
    }
  }
}

# F1 for help on the command line - naturally
Write-Host $stopwatch.Elapsed "set linekeyhandler 13"
Set-PSReadLineKeyHandler -Key F1 `
  -BriefDescription CommandHelp `
  -LongDescription "Open the help window for the current command" `
  -ScriptBlock {
  param($key, $arg)

  $ast = $null
  $tokens = $null
  $errors = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

  $commandAst = $ast.FindAll( {
      $node = $args[0]
      $node -is [CommandAst] -and
      $node.Extent.StartOffset -le $cursor -and
      $node.Extent.EndOffset -ge $cursor
    }, $true) | Select-Object -Last 1

  if ($commandAst -ne $null) {
    $commandName = $commandAst.GetCommandName()
    if ($commandName -ne $null) {
      $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
      if ($command -is [AliasInfo]) {
        $commandName = $command.ResolvedCommandName
      }

      if ($commandName -ne $null) {
        Get-Help $commandName -ShowWindow
      }
    }
  }
}

Write-Host $stopwatch.Elapsed "goto alias"
# goto
New-Alias g goto -Force -Option AllScope

Write-Host $stopwatch.Elapsed "goto function"
function goto {
  param (
    [ValidateSet("temp", "projects", "purplevest", "myoss", "oss-my", "temp-q", "scripts")] $location
  )

  Switch ($location) {
    "temp" { $path = "D:\temp" }
    "projects" { $path = "Q:\" }
    "purplevest" { $path = "Q:\negishut-il\purple-vest-il" }
    "myoss" { $path = "Q:\my-oss" }
    "oss-my" { $path = "Q:\my-oss" }
    "temp-q" { $path = "Q:\temp" }
    "scripts" { $path = "Q:\scripts" }
  }

  Set-Location -Path $path
}

Write-Host $stopwatch.Elapsed "dotnet shortcut 1"
function Get-DotnetBuildCommand { & dotnet build $args }
New-Alias -Name db -Value Get-DotnetBuildCommand -Force -Option AllScope
Write-Host $stopwatch.Elapsed "dotnet shortcut 2"
function Get-DotnetTestCommand { & dotnet test $args }
New-Alias -Name dt -Value Get-DotnetTestCommand -Force -Option AllScope
Write-Host $stopwatch.Elapsed "dotnet shortcut 3"
function Get-DotnetCleanCommand { & dotnet clean $args }
New-Alias -Name dc -Value Get-DotnetCleanCommand -Force -Option AllScope

Write-Host $stopwatch.Elapsed "pnpm i shortcut"
function Get-PnpmInstallCommand { & pnpm install $args }
New-Alias -Name pi -Value Get-PnpmInstallCommand -Force -Option AllScope

Write-Host $stopwatch.Elapsed "touch function"
Function touch {
  param (
    [Parameter(
      Mandatory = $true,
      Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $File
  )

  if (Test-Path $File) {
    (Get-ChildItem $File).LastWriteTime = Get-Date
  }
  else {
    New-Item -Type File $File | Out-Null
  }
}

$stopwatch.Stop()

