class Clip < Formula
  desc "Cross-platform clipboard utility"
  homepage "https://github.com/EvanDurfee/clip"
  url "https://github.com/EvanDurfee/clip/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "5b0a26ec1bf7e2fc97bae071dd3e1372d0294cf4e5e90cf2ad6b85a4644cfd59"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on :linux
  # Expects wl-copy and wl-paste from host, but can we specify that?

  def install
    bin.install "bin/clip.sh" => "clip"
    zsh_completion.install "completions/zsh/_clip"
  end

  test do
    system "#{bin}/clip", "--help"
    # No wayland session available to test, what more to do?
    # assert_equal "hi there", shell_output("/usr/bin/sh -c 'echo hi there | #{bin}/clip -i && #{bin}/clip -o'").strip
  end
end
