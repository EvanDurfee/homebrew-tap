cask "jetbrains-rustrover-eap" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3,253.28294.127"
  sha256 x86_64_linux: "b758a84eb88761361012bd381a0d05b926cdb0183210165963b3856981de9d33",
         arm64_linux:  "eef920ef4bc34a2a38c2d7df8d8a8205e305a89a10c026b3fadd724059aa1fbe"

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
    File.write("#{staged_path}/RustRover-#{version.csv.second}/bin/rustrover64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    File.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{HOMEBREW_PREFIX}/Caskroom/jetbrains-rustrover-eap/#{version}/RustRover-#{version.csv.second}/bin/rustrover' "$@"
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
