using module .\Config.psm1;

class Mercurial {

	static [string] $DIR_NAME = '.hg';

	[System.IO.FileSystemInfo] $Path;

	Mercurial([System.IO.FileSystemInfo] $Path) {
		$this.Path = $Path;
		[Config] $Config = [Config]::Get();
		if (!$Config.Data['repositories'][$this.ToString()]) {
			$Config.Data['repositories'][$this.ToString()] = @{
				bookmarks = @{};
			};
			$Config.Save();
		}
	}

	[void] Shelve() {
		Invoke-Expression 'hg shelve -A';
	}

	[void] Update([string] $Rev) {
		Invoke-Expressoin "hg update $($Rev)";
	}

	[string[]] Bookmarks() {
		$Output = Invoke-Expression 'hg bookmarks --template "{bookmark} "';
		return $Output -split " ";
	}

	[void] CreateBookmark([string] $Name) {
		Invoke-Expression "hg bookmark $($Name)";
	}

	[string] GetActiveBookmark() {
		$Result = hg log -r . -A '{activebookmark}';
		return $Result ? $Result : $null;
	}

	[string] ToString() {
		return $this.Path.FullName;
	}

	static [boolean] Installed() {
		try {
			Get-Command "hg";
			return $true;
		} catch {
			return $false;
		}
	}
	
	static [Mercurial] Current() {
		if (![Mercurial]::Installed()) {
			return $null;
		}
		$CurrentItem = Get-Item -Path ".";
		while ($CurrentItem -ne $null -and !(Test-Path "$($CurrentItem.FullName)\$([Mercurial]::DIR_NAME)")) {
			$CurrentItem = $CurrentItem.Parent;
		}
		if ($CurrentItem -eq $null) {
			return $null;
		} else {
			return [Mercurial]::New($CurrentItem);
		}
	}
}
