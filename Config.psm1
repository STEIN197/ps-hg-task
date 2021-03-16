class Config {

	static [string] $FILE_NAME = 'config.json';

	[hashtable] $Data = $null;
	[string] $Path;

	Config([System.IO.FileSystemInfo] $Directory) {
		$this.Path = "$($Directory)\$([Config]::FILE_NAME)";
		$this.Load();
	}

	[void] Save() {
		$this.Data | ConvertTo-Json | Out-File -FilePath $this.Path;
	}

	[void] Load() {
		$this.Data = Get-Content -Path $this.Path -Raw | ConvertFrom-Json -AsHashtable;
		$this.Data ??= @{};
	}

	static [boolean] Exists() {
		return Test-Path -Path "$($PSScriptRoot)\$([Config]::FILE_NAME)";
	}

	static [Config] Create() {
		New-Item -Path $PSScriptRoot -Name "$([Config]::FILE_NAME)" -ItemType "file";
		return [Config]::Get();
	}

	static [Config] Get() {
		if ([Config]::Exists()) {
			return [Config]::New((Get-Item -Path $PSScriptRoot));
		} else {
			return $null;
		}
	}
}
