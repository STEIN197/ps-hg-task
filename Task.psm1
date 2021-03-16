using module .\Config.psm1;
using module .\Mercurial.psm1;

class Task {

	[int] $ID;
	[string] $Description;

	Task([int] $ID, [string] $Description) {
		$this.ID = $ID;
		$this.Description = $Description;
	}

	static [boolean] Exists([int] $ID) {
		return [Mercurial]::Current().Bookmarks().Contains("$([Config]::Get().Data['prefix'])-$($ID)");
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
