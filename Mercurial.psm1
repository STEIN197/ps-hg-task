class Mercurial {

	static [string] $DIR_NAME = '.hg';

	static [boolean] Exists() {
		$CurrentItem = Get-Item -Path ".";
		while ($CurrentItem -ne $null -and !(Test-Path "$($CurrentItem.FullName)\$([Mercurial]::DIR_NAME)")) {
			$CurrentItem = $CurrentItem.Parent;
		}
		return $CurrentItem -ne $null;
	}
	
	static [Mercurial] Current() {
		if ([Mercurial]::Exists()) {
			return [Mercurial]::New();
		} else {
			return $null;
		}
	}
}
