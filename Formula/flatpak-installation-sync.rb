class FlatpakInstallationSync < Formula
  desc "Automate installation of flatpaks"
  homepage "https://github.com/EvanDurfee/distro-utils"
  url "https://github.com/EvanDurfee/distro-utils/archive/refs/tags/v0.0.2.tar.gz"
  sha256 "452d4a9f1325f35ea4ad7bdc13cb4c48a1763eee061fd08b7f61887f6346aedb"
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
