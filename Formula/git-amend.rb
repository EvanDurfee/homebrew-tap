class GitAmend < Formula
  desc "Git plugin to amend any commit in history with the staged changes"
  homepage "https://github.com/EvanDurfee/git-amend"
  url "https://github.com/EvanDurfee/git-amend/releases/download/v0.1.0/git-amend-0.1.0.tar.gz"
  sha256 "a98f0d049798c38b0b831fe188ce95ee1c9e45262b199ca97fd1d6c59b575b9b"
  license "MPL-2.0"
  head "https://github.com/EvanDurfee/git-amend.git", branch: "master"

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
      libexec.install "bin/git-amend"
      (bin/"git-amend").write_env_script libexec/"git-amend", PATH: "#{formula_opt_bin("gnu-getopt")}:$PATH"
    else
      bin.install "bin/git-amend"
    end

    man1.install "man/git-amend.1"
    bash_completion.install "completions/git-amend.bash" => "git-amend"
    zsh_completion.install "completions/_git-amend"
  end

  test do
    assert_match "COMMIT_REF", shell_output("#{bin}/git-amend --help")

    ENV["GIT_AUTHOR_NAME"] = ENV["GIT_COMMITTER_NAME"] = "test"
    ENV["GIT_AUTHOR_EMAIL"] = ENV["GIT_COMMITTER_EMAIL"] = "test@example.com"
    system "git", "init", "--initial-branch=master"
    (testpath/"a").write "a"
    system "git", "add", "a"
    system "git", "commit", "-m", "first"
    system "git", "commit", "--allow-empty", "-m", "second"

    (testpath/"b").write "b"
    system "git", "add", "b"
    system bin/"git-amend", "--no-edit", "HEAD~1"
    assert_equal "a\nb", shell_output("git ls-tree --name-only HEAD~1").strip
    assert_equal "first", shell_output("git log -1 --format=%s HEAD~1").strip
  end
end
