class GitExclude < Formula
  desc "Git plugin to add patterns to the repository's info/exclude file"
  homepage "https://github.com/EvanDurfee/git-exclude"
  url "https://github.com/EvanDurfee/git-exclude/releases/download/v0.1.0/git-exclude-0.1.0.tar.gz"
  sha256 "92122286675ae812e32633d9aed66caba99c594484f16c72622d7d531443a372"
  license "MPL-2.0"
  head "https://github.com/EvanDurfee/git-exclude.git", branch: "master"

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
      libexec.install "bin/git-exclude"
      (bin/"git-exclude").write_env_script libexec/"git-exclude", PATH: "#{formula_opt_bin("gnu-getopt")}:$PATH"
    else
      bin.install "bin/git-exclude"
    end

    man1.install "man/git-exclude.1"
    bash_completion.install "completions/git-exclude.bash" => "git-exclude"
    zsh_completion.install "completions/_git-exclude"
  end

  test do
    assert_match "PATTERN", shell_output("#{bin}/git-exclude --help")

    system "git", "init", "--initial-branch=master"
    (testpath/"sub").mkpath
    cd "sub" do
      system bin/"git-exclude", "*.log"
      system bin/"git-exclude", "*.log"
    end
    assert_equal "*.log", (testpath/".git/info/exclude").read.lines.grep(/\.log/).join.strip
    system "git", "check-ignore", "--quiet", "sub/debug.log"
  end
end
