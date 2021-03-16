using module .\Task.psm1;
using module .\Mercurial.psm1;
using module .\Config.psm1;

class CLI {

	# TODO
	static [void] Jump([string[]] $Params) {
		# [int] $TaskID = $Args[0];
		# [Mercurial] $Repo = [Mercurial]::Get();
		# if ($Repo.Bookmarks().Contains()) {
		# 	[Mercurial] $Repo = [Mercurial]::Get();
		# 	$Repo.Shelve();
		# 	$Repo.Update()
		# } else {
		# 	throw "Task `"$($TaskID)`" does not exist";
		# }
	}

	# TODO
	static [void] List([string[]] $Params) {}
	# TODO
	static [void] Create([string[]] $Params) {
		# [int] $TaskID = $Args[0];
		# [string] $TaskDescription = $Args[1];
		# if ([Task]::Exists($TaskID)) {
		# 	throw "Task with ID `"$($TaskID)`" already exists";
		# } else {
		# 	[Task] $Task = [Task]::Create($TaskID, $TaskDescription);
			
		# 	$Task.Activate();
		# }
	}
	# TODO
	static [void] Apply([string[]] $Params) {write-host 'apply'}
	# TODO
	static [void] Push([string[]] $Params) {}

	static [void] Config([string[]] $Params) {
		[string] $Key = $Params[0];
		[string] $Value = $Params[1];
		if ([Config]::PROPERTY_RESERVED.Contains($Key)) {
			throw "Cannot set reserved property `"$($Key)`"";
		}
		$Config = [Config]::Get();
		if ($Value) {
			$Config.Data[$Key] = $Value;
			$Config.Save();
		} else {
			Write-Host $Config.Data[$Key];
		}
	}
}
