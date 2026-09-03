#!/usr/bin/env bash
set -euo pipefail

VARIANT="$1"
POD_LINE="$2"

rm -rf "probe/$VARIANT"
mkdir -p "probe/$VARIANT"
cd "probe/$VARIANT"
cp ../make_project.rb .
ruby make_project.rb

cat > Podfile <<PODFILE_EOF
source 'https://cdn.cocoapods.org/'
platform :ios, '14.0'

use_frameworks!
install! 'cocoapods', :warn_for_unused_master_specs_repo => false

target 'unimoduleProbe' do
  ${POD_LINE}
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACH_O_TYPE'] = "staticlib"
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'NO'
      config.build_settings['GCC_WARN_PEDANTIC'] = 'YES'
      config.build_settings['GCC_WARN_PEDANTIC_WARNINGS'] = 'YES'
      config.build_settings['CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION'] = 'NO'
    end
  end
end
PODFILE_EOF

if pod install --verbose > pod-install.log 2>&1; then
  echo "POD INSTALL OK [$VARIANT]"
else
  echo "POD INSTALL FAILED [$VARIANT]"
  tail -n 200 pod-install.log
  exit 1
fi

mkdir -p ../results/$VARIANT

find Pods -path '*Target Support Files*' -name '*.xcconfig' > ../results/$VARIANT/xcconfig-files.txt || true
: > ../results/$VARIANT/xcconfig-dump.txt
while IFS= read -r f; do
  echo "### $f" >> ../results/$VARIANT/xcconfig-dump.txt
  cat "$f" >> ../results/$VARIANT/xcconfig-dump.txt
done < ../results/$VARIANT/xcconfig-files.txt

grep -R -n -E 'OTHER_LDFLAGS|FRAMEWORK_SEARCH_PATHS|LIBRARY_SEARCH_PATHS' Pods/Target\ Support\ Files > ../results/$VARIANT/link-flags.txt || true
find Pods -maxdepth 6 \( -name '*.framework' -o -name '*.a' \) -print > ../results/$VARIANT/vendored-files.txt || true
ls -la Pods > ../results/$VARIANT/pods-top.txt || true
du -sh Pods >> ../results/$VARIANT/pods-top.txt || true
cp pod-install.log ../results/$VARIANT/pod-install.log
tail -n 120 pod-install.log > ../results/$VARIANT/pod-install-tail.log

if xcodebuild -workspace Probe.xcworkspace -scheme unimoduleProbe -configuration Debug \
     -sdk iphoneos -arch arm64 ONLY_ACTIVE_ARCH=NO CODE_SIGNING_ALLOWED=NO \
     build > build.log 2>&1; then
  echo "XCODEBUILD OK [$VARIANT]" | tee -a ../results/$VARIANT/build-result.txt
else
  echo "XCODEBUILD FAILED [$VARIANT]" | tee -a ../results/$VARIANT/build-result.txt
  tail -n 120 build.log >> ../results/$VARIANT/build-result.txt
fi
cp build.log ../results/$VARIANT/build.log

echo "DONE [$VARIANT]"
