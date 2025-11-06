cask "jetbrains-rider-eap" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3-EAP8,253.28086.30"
  sha256 x86_64_linux: "613def95c031b4d5499d9e810a9d5e069807ffd3f8b2915d10378df7ad438017",
         arm64_linux:  "377bd20b9aabbb50e96198f8f2cfe4ad699e35200dfdfa08ec2bb7ebfd7e4d6c"

  url "https://download.jetbrains.com/rider/JetBrains.Rider-#{version.csv.first}-#{version.csv.second}.Checked#{arch}.tar.gz"
  name "Rider EAP"
  desc ".NET IDE Early Access Program"
  homepage "https://www.jetbrains.com/rider/nextversion"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=RD&release.type=eap"
    strategy :json do |json|
      json["RD"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: ["jetbrains-toolbox", "jetbrains-rider"]

  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/rider.wrapper.sh"
  binary shimscript, target: "rider"
  artifact "rider.desktop",
           target: "#{Dir.home}/.local/share/applications/rider.desktop"
  artifact "JetBrains Rider-#{version.csv.second}/bin/rider.svg",
           target: "#{Dir.home}/.local/share/icons/rider.svg"
  artifact "JetBrains Rider-#{version.csv.second}/bin/rider.png",
           target: "#{Dir.home}/.local/share/icons/rider.png"

  preflight do
    File.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{HOMEBREW_PREFIX}/Caskroom/jetbrains-rider-eap/#{version}/JetBrains Rider-#{version.csv.second}/bin/rider' -Dide.no.platform.update=true "$@"
    EOS
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/rider.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=Rider
      Comment=JetBrains .NET IDE
      Exec=#{HOMEBREW_PREFIX}/bin/rider %u
      Icon=rider
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;c#;f#;dotnet;.net;
      Terminal=false
      StartupWMClass=jetbrains-rider
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/Rider#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/Rider#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/Rider#{version.major_minor}",
  ]
end
