class GitWts < Formula
  desc "Git plugin to manage a worktree project layout and sync local files"
  homepage "https://github.com/EvanDurfee/git-wts"
  url "https://github.com/EvanDurfee/git-wts/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "64baf261b3415a1d172d418df3d6b940a4b645fc1e2204596a4b9f17f0f6fff2"
  license "MPL-2.0"
  head "https://github.com/EvanDurfee/git-wts.git", branch: "master"

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
      libexec.install "bin/git-wts"
      (bin/"git-wts").write_env_script libexec/"git-wts", PATH: "#{formula_opt_bin("gnu-getopt")}:$PATH"
    else
      bin.install "bin/git-wts"
    end
    pkgshare.install "share/git-wts/hooks"

    man1.install "man/git-wts.1"
    bash_completion.install "completions/git-wts.bash" => "git-wts"
    zsh_completion.install "completions/_git-wts"
  end

  test do
    assert_match "clone", shell_output("#{bin}/git-wts --help")

    ENV["GIT_AUTHOR_NAME"] = ENV["GIT_COMMITTER_NAME"] = "test"
    ENV["GIT_AUTHOR_EMAIL"] = ENV["GIT_COMMITTER_EMAIL"] = "test@example.com"
    system "git", "init", "--initial-branch=master", "origin"
    system "git", "-C", "origin", "commit", "--allow-empty", "-m", "init"
    system bin/"git-wts", "clone", testpath/"origin", "project"
    assert_path_exists testpath/"project/.remote.bare/hooks/post-checkout"
    assert_path_exists testpath/"project/.worktreesync.bare/hooks/post-receive"
  end
end
