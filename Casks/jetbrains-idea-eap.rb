cask "jetbrains-idea-eap" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3,253.28086.51"
  sha256 x86_64_linux: "4bab2677f95d13f88cffe1d377f31f82c164da1bce44356ee687bcd7305e726f",
         arm64_linux:  "f688a375375aef2485841ad98b0ac7d63205da076f140da13f5d9d67f70425cd"

  url "https://download.jetbrains.com/idea/ideaIU-#{version.csv.second}#{arch}.tar.gz"
  name "IntelliJ IDEA Ultimate EAP"
  desc "Java IDE by JetBrains Early Access Program"
  homepage "https://www.jetbrains.com/idea/nextversion"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=IIU&release.type=eap"
    strategy :json do |json|
      json["IIU"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: ["jetbrains-toolbox", "jetbrains-idea"]

  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/idea.wrapper.sh"
  binary shimscript, target: "idea"
  artifact "idea.desktop",
           target: "#{Dir.home}/.local/share/applications/idea.desktop"
  artifact "idea-IU-#{version.csv.second}/bin/idea.svg",
           target: "#{Dir.home}/.local/share/icons/idea.svg"
  artifact "idea-IU-#{version.csv.second}/bin/idea.png",
           target: "#{Dir.home}/.local/share/icons/idea.png"

  preflight do
    File.write("#{staged_path}/idea-IU-#{version.csv.second}/bin/idea64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    File.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{HOMEBREW_PREFIX}/Caskroom/jetbrains-idea-eap/#{version}/idea-IU-#{version.csv.second}/bin/idea' "$@"
    EOS
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/idea.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=Intellij IDEA
      Comment=JetBrains Java IDE
      Exec=#{HOMEBREW_PREFIX}/bin/idea %u
      Icon=idea
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;java;groovy;kotlin;scala;
      Terminal=false
      StartupWMClass=jetbrains-idea
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/IntelliJIdea#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/IntelliJIdea#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/IntelliJIdea#{version.major_minor}",
  ]
end
