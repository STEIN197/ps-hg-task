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
	# if (-not (hg-exists)) {
	# }
	# if (!($args.length)) {
	# }
	# [string] $action = $args[0];
	# if (!(is-numeric $args[1])) {
	# 	throw "Task ID '$($args[1])' should be numeric";
	# }
	# [int] $taskID = $args[1];
	# switch ($action) {
	# 	"create" {
	# 		if ([Task]::exists($args[1])) {
				
	# 		}
	# 		# there is task with name
	# 		write-host "creating task...";
	# 	}
	# 	"delete" {
	# 		# no task with this name
	# 		write-host "deleting task..."
	# 	}
	# 	"push" {

	# 	}
	# 	default {
	# 		[string] $taskID = $action;
	# 		if (!($taskID -match '^\d+$')) {
	# 			throw "Task name must be a numeric identifier";
	# 		}
	# 		# test regxep
	# 		write-host "switching...";
	# 	}
	# }
}

try {
	Main $Args;
} catch {
	Write-Host $PSItem -ForegroundColor Red;
	exit 1;
}
