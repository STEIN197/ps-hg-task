using module .\TaskData.psm1;
using module .\Mercurial.psm1;

function Main {
	if (![Mercurial]::Exists()) {
		throw "Mercurial repository does not exist here";
	}
	if (![TaskData]::Exists()) {
		[TaskData]::Create();
	}
	if (!$Args.Length) {
		throw "No arguments provided";
	}
	[TaskData] $TaskData = [TaskData]::Get();
	[Mercurial] $Mercurial = [Mercurial]::Current();
}

try {
	Main @Args;
} catch {
	Write-Host $PSItem -ForegroundColor Red;
	exit 1;
}
