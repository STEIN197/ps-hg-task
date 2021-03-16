using module .\Task.psm1;
using module .\Config.psm1;
using module .\Mercurial.psm1;
using module .\Util.psm1;
using module .\CLI.psm1;

function Main {
	if (![Mercurial]::Installed()) {
		throw "Mercurial is not installed on this computer";
	}
	if (![Mercurial]::Current()) {
		throw "Mercurial repository does not exist here";
	}
	if (!$Args.Length) {
		throw "No arguments provided";
	}
	if (![Config]::Exists()) {
		[Config]::Create();
	}
	[string] $Action = $Args[0];
	if ($Args[1] -and ![Util]::IsNumeric($Args[1])) {
		throw "Task ID `"$($Args[1])`" must be a numeric identifier";
	}
	[string] $ActionRegex = $Action -split '' -match '[a-z]' -join '.*';
	$ActionRegex = "^$($ActionRegex)";
	[CLI] | Get-Member -Static -MemberType Method | % {
		if ($_.Name -match $ActionRegex) {
			$Action = $_.Name;
			return;
		}
	}
	if (!([CLI] | Get-Member -Name $Action -Static)) {
		throw "Unknown operation `"$($Action)`"";
	}
	[CLI]::$Action($Args[1..$Args.Length]);
}

try {
	Main @Args;
} catch {
	Write-Host $_ -ForegroundColor Red;
	exit 1;
}
