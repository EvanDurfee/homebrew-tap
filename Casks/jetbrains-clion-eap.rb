cask "jetbrains-clion-eap" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3,253.28294.125"
  sha256 x86_64_linux: "4519969bdedab477aaaa694f0c0f64c3b722b1c2a94dd8f32030f852377da497",
         arm64_linux:  "b8333127e2e2b794396f74ae0e4eddf6507fbd781bbdd09b90b98fae1dda98e0"

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
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/clion.svg"

  preflight do
    File.write("#{staged_path}/clion-#{version.csv.second}/bin/clion64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    File.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{HOMEBREW_PREFIX}/Caskroom/jetbrains-clion-eap/#{version}/clion-#{version.csv.second}/bin/clion' "$@"
    EOS
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
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

  postflight do
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/CLion#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/CLion#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/CLion#{version.major_minor}",
  ]
end
