cask "clion-linux" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2026.1.3,261.25134.137"
  sha256 x86_64_linux: "c37221089e9f4af957a4b88f677dc35e3658b2135fe0dc9b2b8b951fd9013bf9",
         arm64_linux:  "813a0c40c295db163ff52941aeb22c3d28a5837326e82acb735c2e7b10e67edc"

  url "https://download.jetbrains.com/cpp/CLion-#{version.csv.first}#{arch}.tar.gz"
  name "CLion"
  desc "C and C++ IDE"
  homepage "https://www.jetbrains.com/clion/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=CL&latest=true&type=release"
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
  conflicts_with cask: "jetbrains-toolbox-linux"

  binary "#{HOMEBREW_PREFIX}/Caskroom/clion-linux/#{version}/clion-#{version.csv.first}/bin/clion"
  artifact "jetbrains-clion.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-clion.desktop"
  artifact "clion-#{version.csv.first}/bin/clion.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/clion.svg"

  preflight do
    File.write("#{staged_path}/clion-#{version.csv.first}/bin/clion64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
    File.write("#{staged_path}/jetbrains-clion.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=CLion
      Comment=A cross-platform C and C++ IDE
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
