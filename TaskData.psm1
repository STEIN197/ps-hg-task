class TaskData {

	static [string] $FILE_NAME = '.json';

	[void] Save() {} # TODO

	static [boolean] Exists() {
		return Test-Path -Path "$($PSScriptRoot)\$([TaskData]::FILE_NAME)";
	}

	static [TaskData] Create() {
		if (![TaskData]::Exists()) {
			New-Item -Path $PSScriptRoot -Name "$([TaskData]::FILE_NAME)" -ItemType "file";
		}
		return [TaskData]::Get();
	}

	static [TaskData] Get() {
		if ([TaskData]::Exists()) {
			return [TaskData]::New();
		} else {
			return $null;
		}
	}
}
