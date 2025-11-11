class FlatpakInstallationSync < Formula
  desc "Automate installation of flatpaks"
  homepage "https://github.com/EvanDurfee/distro-utils"
  url "https://github.com/EvanDurfee/distro-utils/archive/refs/tags/v0.0.1.tar.gz"
  sha256 "d55908bd73ec8b14618f93d08697637d3c4190ced8b79be0eb0fd96c72e6a554"
  license "MPL-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on :linux

  def install
    bin.install "flatpak-sync/bin/flatpak-installation-sync"
  end

  test do
    system "#{bin}/flatpak-installation-sync", "--help"
  end
end
