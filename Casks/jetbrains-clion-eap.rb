cask "jetbrains-clion-eap" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3,253.28086.9"
  sha256 x86_64_linux: "8d05123a9975fd9218388fc8945cd04ada9dfc4fdcf1b9f91072733189fdbd5e",
         arm64_linux:  "b69a85ebf056db7cc03f1236209ec3fb15e43c1d414bbde2cc3971cb881a4335"

  url "https://download.jetbrains.com/cpp/CLion-#{version.csv.second}#{arch}.tar.gz"
  name "CLion EAP"
  desc "C and C++ IDE Early Access Program"
  homepage "https://www.jetbrains.com/clion/nextversion"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=CL&release.type=eap"
    strategy :json do |json|
      json["CL"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: ["jetbrains-toolbox", "jetbrains-clion"]

  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/clion.wrapper.sh"
  binary shimscript, target: "clion"
  artifact "clion.desktop",
           target: "#{Dir.home}/.local/share/applications/clion.desktop"
  artifact "clion-#{version.csv.second}/bin/clion.svg",
           target: "#{Dir.home}/.local/share/icons/clion.svg"
  artifact "clion-#{version.csv.second}/bin/clion.png",
           target: "#{Dir.home}/.local/share/icons/clion.png"

  preflight do
    File.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{prefix}/clion-#{version.csv.second}/bin/clion' -Dide.no.platform.update=true "$@"
    EOS
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/clion.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=CLion
      Comment=JetBrains C and C++ IDE
      Exec=#{HOMEBREW_PREFIX}/bin/clion %u
      Icon=clion
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;c;c++;
      Terminal=false
      StartupWMClass=jetbrains-clion
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/CLion#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/CLion#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/CLion#{version.major_minor}",
  ]
end
