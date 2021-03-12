using module .\Task.psm1;
using module .\TaskData.psm1;
using module .\Mercurial.psm1;
using module .\Util.psm1;

function Main {
	if (![Mercurial]::Exists()) {
		throw "Mercurial is not installed on this computer";
	}
	[Mercurial] $Mercurial = [Mercurial]::Current();
	if (!$Mercurial) {
		throw "Mercurial repository does not exist here";
	}
	if (![TaskData]::Exists()) {
		[TaskData]::Create();
	}
	if (!$Args.Length) {
		throw "No arguments provided";
	}
	[TaskData] $TaskData = [TaskData]::Get();
	if ([Util]::IsNumeric($Args[0])) {

	} else {
		[string] $Action = $Args[0];
		if ($Args[1] -and ![Util]::IsNumeric($Args[1])) {
			throw "Task ID `"$($Args[1])`" must be a numeric identifier";
		}
		[int] $TaskID = $Args[1];
		switch ($Action) {
			"list" {}
			"create" {
				if ([Task]::Exists($TaskID)) {
					throw "Task with ID `"$($TaskID)`" already exists";
				} else {
					[Task] $Task = [Task]::Create($TaskID, $Args[2]);
				}
			}
			"delete" {}
			"apply" {}
			"push" {}
			default {
				throw "Unknown operation `"$($Action)`"";
			}
		}
	}
}

try {
	Main @Args;
} catch {
	Write-Host $PSItem -ForegroundColor Red;
	exit 1;
}
