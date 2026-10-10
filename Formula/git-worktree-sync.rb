class GitWorktreeSync < Formula
  desc "Git plugin to manage a worktree project layout and sync local files"
  homepage "https://github.com/EvanDurfee/git-worktree-sync"
  url "https://github.com/EvanDurfee/git-worktree-sync/releases/download/v0.2.0/git-worktree-sync-0.2.0.tar.gz"
  sha256 "6258b0080a80f541b002ea5e1d91e553b73b4aa7e4b153d1f4e3ae370157ac0c"
  license "MPL-2.0"
  head "https://github.com/EvanDurfee/git-worktree-sync.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    # Requires util-linux (enhanced) getopt
    depends_on "gnu-getopt"
  end

  def install
    if OS.mac?
      # Keep the script one level below prefix so it still finds pkgshare/hooks
      libexec.install "bin/git-worktree-sync"
      (bin/"git-worktree-sync").write_env_script libexec/"git-worktree-sync",
                                                 PATH: "#{formula_opt_bin("gnu-getopt")}:$PATH"
    else
      bin.install "bin/git-worktree-sync"
    end
    pkgshare.install "share/git-worktree-sync/hooks"

    man1.install "man/git-worktree-sync.1"
    bash_completion.install "completions/git-worktree-sync.bash" => "git-worktree-sync"
    zsh_completion.install "completions/_git-worktree-sync"
  end

  test do
    assert_match "clone", shell_output("#{bin}/git-worktree-sync --help")

    ENV["GIT_AUTHOR_NAME"] = ENV["GIT_COMMITTER_NAME"] = "test"
    ENV["GIT_AUTHOR_EMAIL"] = ENV["GIT_COMMITTER_EMAIL"] = "test@example.com"
    system "git", "init", "--initial-branch=master", "origin"
    system "git", "-C", "origin", "commit", "--allow-empty", "-m", "init"
    system bin/"git-worktree-sync", "clone", testpath/"origin", "project"
    assert_path_exists testpath/"project/.remote.bare/hooks/post-checkout"
    assert_path_exists testpath/"project/.worktreesync.bare/hooks/post-receive"
  end
end
