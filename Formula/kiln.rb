class Kiln < Formula
  desc "Template compiler for GFI (gulp-file-include) syntax"
  homepage "https://github.com/teehemkay/homebrew-kiln"
  version "2026.06.10.01"

  on_macos do
    on_arm do
      url "https://github.com/teehemkay/homebrew-kiln/releases/download/2026.06.10.01/kiln-2026.06.10.01-darwin-arm64"
      sha256 "e8ddee65f2954bdc85a8768595f858bce66cff05af84ecbc94ff05f45f81da46"
    end
    on_intel do
      url "https://github.com/teehemkay/homebrew-kiln/releases/download/2026.06.10.01/kiln-2026.06.10.01-darwin-x64"
      sha256 "da21faf6bab6ea8f31a05b62f5d24dbc510851a2ac87a2630e8c9da28270283d"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/teehemkay/homebrew-kiln/releases/download/2026.06.10.01/kiln-2026.06.10.01-linux-x64"
      sha256 "638075cb03649b430ab469fe097ffa3af1d6ea54547bc829d0285cabed4f1470"
    end
  end

  def install
    asset = Dir["kiln-*"].first
    chmod 0555, asset
    bin.install asset => "kiln"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kiln --version")
  end
end
