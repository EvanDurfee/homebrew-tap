cask "jetbrains-clion" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.3,252.26830.83"
  sha256 x86_64_linux: "364502648a5f1480bd06a00ee410968d224f96b263c78f5148614063f7bc3961",
         arm64_linux:  "e4cc668cb1e0cf5b976ab8eb3997388f1e7cc673e51af3f3c6afa3666a9c47b6"

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
  conflicts_with cask: "jetbrains-toolbox"

  binary "clion-#{version.csv.first}/bin/clion"
  artifact "clion.desktop",
           target: "#{Dir.home}/.local/share/applications/clion.desktop"
  artifact "clion-#{version.csv.first}/bin/clion.svg",
           target: "#{Dir.home}/.local/share/icons/clion.svg"
  artifact "clion-#{version.csv.first}/bin/clion.png",
           target: "#{Dir.home}/.local/share/icons/clion.png"

  preflight do
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/clion.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=CLion
      Comment=JetBrains C and C++ IDE
      Exec=#{HOMEBREW_PREFIX}/bin/clion -Dawt.toolkit.name=WLToolkit %u
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
