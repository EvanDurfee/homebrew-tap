class FreedesktopColorSchemeMonitor < Formula
  desc "Service for triggering callback scripts on freedesktop color-scheme changes"
  homepage "https://github.com/EvanDurfee/freedesktop-color-scheme-monitor"
  url "https://github.com/EvanDurfee/freedesktop-color-scheme-monitor/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "0f37dd7f84f67e9402a38662750b8c33b2b4fc0c603f1fca02c2fd4df3b4f6f0"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on :linux

  def install
    # Update the path in the systemd service to match our installation dir
    modified_unit = File.read("systemd/color-scheme-monitor.service")
                        .gsub!("ExecStart=/bin/sh -c 'exec \"${XDG_DATA_HOME:-\"$HOME\"/" \
                               ".local/share}\"/color-scheme/color-scheme-monitor.sh'",
                               "ExecStart=#{libexec}/color-scheme-monitor.sh")
    File.write("color-scheme-monitor.service", modified_unit)

    libexec.install "color-scheme/color-scheme-monitor.sh" => "color-scheme-monitor.sh"
    # Installing this to opt breaks things badly during the install process; where does it go?
    # opt_prefix.install "color-scheme-monitor.service" => "color-scheme-monitor.service"
    prefix.install "color-scheme-monitor.service"
  end

  service do
    name linux: "color-scheme-monitor"
  end

  def caveats
    <<~EOS
      Enable the service with `brew services start freedesktop-color-scheme-monitor`
      Disable the service with `brew services stop freedesktop-color-scheme-monitor`
      Callbacks will be executed from "${XDG_DATA_HOME}/color-scheme/scripts/"
      Bear in mind that brew does not remove the service when uninstalling the formula.
    EOS
  end

  test do
    # There is no useful test here without dbus and systemd, so just verify the
    # files exist as expected
    system "test", "-e", "#{libexec}/color-scheme-monitor.sh"
    system "test", "-e", "#{prefix}/color-scheme-monitor.service"
  end
end
