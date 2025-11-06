cask "jetbrains-goland-eap" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3,253.28086.52"
  sha256 x86_64_linux: "961d9a10df34d6efac825e528ff6d677064d2740f56678d9fd77aba1441b5aa9",
         arm64_linux:  "9b11169f330393e98e13364a049e9df862484dba484e06f1f965920f4cd1dd72"

  url "https://download.jetbrains.com/go/goland-#{version.csv.second}#{arch}.tar.gz"
  name "GoLand EAP"
  desc "Go (golang) IDE Early Access Program"
  homepage "https://www.jetbrains.com/goland/nextversion"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=GO&release.type=eap"
    strategy :json do |json|
      json["GO"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: ["jetbrains-toolbox", "jetbrains-goland"]

  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/goland.wrapper.sh"
  binary shimscript, target: "goland"
  artifact "goland.desktop",
           target: "#{Dir.home}/.local/share/applications/goland.desktop"
  artifact "GoLand-#{version.csv.second}/bin/goland.svg",
           target: "#{Dir.home}/.local/share/icons/goland.svg"
  artifact "GoLand-#{version.csv.second}/bin/goland.png",
           target: "#{Dir.home}/.local/share/icons/goland.png"

  preflight do
    File.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{prefix}/GoLand-#{version.csv.second}/bin/goland' -Dide.no.platform.update=true "$@"
    EOS
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/goland.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=GoLand
      Comment=JetBrains Golang IDE
      Exec=#{HOMEBREW_PREFIX}/bin/goland %u
      Icon=goland
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;go;golang;
      Terminal=false
      StartupWMClass=jetbrains-goland
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/GoLand#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/GoLand#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/GoLand#{version.major_minor}",
  ]
end
