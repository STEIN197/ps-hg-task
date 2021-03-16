using module .\Task.psm1;

class CLI {

	static [void] Jump([string[]] $Args) {Write-Host 'jump'}
	static [void] List([string[]] $Args) {write-host 'list'}

	static [void] Create([string[]] $Args) {
		# [int] $TaskID = $Args[0];
		# [string] $TaskDescription = $Args[1];
		# if ([Task]::Exists($TaskID)) {
		# 	throw "Task with ID `"$($TaskID)`" already exists";
		# } else {
		# 	[Task] $Task = [Task]::Create($TaskID, $TaskDescription);
			
		# 	$Task.Activate();
		# }
	}

	static [void] Apply([string[]] $Args) {write-host 'apply'}
	static [void] Push([string[]] $Args) {
		# [Task]::Get($TaskID).Push();
	}
}
