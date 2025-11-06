cask "jetbrains-rustrover-eap" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3,253.28294.15"
  sha256 x86_64_linux: "1507f63c0fb30b5e954dba01ab7c9210a29bf360f11f5359429e890d7fbb8caa",
         arm64_linux:  "fe1bb2ebdb05fc415496d756b04fda1655a52eb16905903c6b049d397185d704"

  url "https://download.jetbrains.com/rustrover/RustRover-#{version.csv.second}#{arch}.tar.gz"
  name "RustRover EAP"
  desc "Rust IDE Early Access Program"
  homepage "https://www.jetbrains.com/rustrover/nextversion"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=RR&release.type=eap"
    strategy :json do |json|
      json["RR"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: ["jetbrains-toolbox", "jetbrains-rustrover"]

  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/rustrover.wrapper.sh"
  binary shimscript, target: "rustrover"
  artifact "rustrover.desktop",
           target: "#{Dir.home}/.local/share/applications/rustrover.desktop"
  artifact "RustRover-#{version.csv.second}/bin/rustrover.svg",
           target: "#{Dir.home}/.local/share/icons/rustrover.svg"
  artifact "RustRover-#{version.csv.second}/bin/rustrover.png",
           target: "#{Dir.home}/.local/share/icons/rustrover.png"

  preflight do
    File.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{prefix}/RustRover-#{version.csv.second}/bin/rustrover' -Dide.no.platform.update=true "$@"
    EOS
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/rustrover.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=RustRover
      Comment=JetBrains Rust IDE
      Exec=#{HOMEBREW_PREFIX}/bin/rustrover %u
      Icon=rustrover
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;rust;
      Terminal=false
      StartupWMClass=jetbrains-rustrover
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/RustRover#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/RustRover#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/RustRover#{version.major_minor}",
  ]
end
