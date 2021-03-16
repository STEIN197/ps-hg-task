using module .\Mercurial.psm1;

class Task {

	static [string] $PREFIX = 'kissmedev';

	[int] $ID;
	[string] $Description;

	Task([int] $ID, [string] $Description) {
		$this.ID = $ID;
		$this.Description = $Description;
	}

	[void] Push() {
		[Mercurial]::Current().PushBookmark("$([Task]::PREFIX)-$($this.ID)");
	}

	static [boolean] Exists([int] $ID) {
		return [Mercurial]::Current().Bookmarks().Contains("$([Task]::PREFIX)-$($ID)");
	}

	# static [Task] Create([int] $ID, [string] $Description) {
	# 	$Repo = [Mercurial]::Current();
	# 	$Repo.CreateBookmark("$([Task]::PREFIX)-$($ID)");
	# 	if ($Description) {
	# 		# TODO
	# 	}
	# }

	# static [Task] Get([int] $TaskID) {}
}
