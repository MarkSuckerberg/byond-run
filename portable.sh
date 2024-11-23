folder=$(dirname "$(realpath "$0")")
prefix=$folder/.wine32
wine=$(which wine)
winetricks=$(which winetricks)

export WINEARCH=win32
export WINEPREFIX=$prefix
export WINEESYNC=1
export WINE_LARGE_ADDRESS_AWARE=1
#export WINE_D3D_CONFIG="renderer=vulkan;VideoPciVendorID=0xc0de"

wineserver -p=10

$winetricks -q --force vcrun2022
$winetricks -q dxtrans dxvk ie8 ie8_kb2936068

DEBUG_SERVER_TAG=v2.3.3

curl https://www.byond.com/download/build/515/515.1646_byond.zip -so $folder/byond.zip -C -
unzip -o $folder/byond.zip -d $folder > /dev/null

curl https://github.com/willox/auxtools/releases/download/$DEBUG_SERVER_TAG/debug_server.dll -so $prefix/drive_c/debug_server.dll -C -

ln -sf $folder/byond/help $folder

mkdir -p $folder/bin
for program in $(ls $folder/byond/bin/*.exe); do
    output=$folder/bin/$(basename $program)
    echo "#!/bin/bash" > $output
    echo "export WINEPREFIX=$prefix" >> $output
    echo "export WINE_D3D_CONFIG=$WINE_D3D_CONFIG" >> $output
    echo "export WINEDEBUG=-all" >> $output
    echo "export WINE_LARGE_ADDRESS_AWARE=1" >> $output
    echo "export WINEESYNC=$WINEESYNC" >> $output
    echo "export AUXTOOLS_BUNDLE_DLL=$(winepath -w $prefix/drive_c/debug_server.dll)" >> $output
    echo "export AUXTOOLS_COMMIT_HASH=$DEBUG_SERVER_TAG" >> $output

    echo "gamemoderun $wine $program \"\$@\"" >> $output
    chmod +x $output
done

cp $folder/byond/bin/*.dll $folder/bin

echo "export WINEPREFIX=$prefix" > $folder/bin/kill.sh
echo "wineserver -k" >> $folder/bin/kill.sh
chmod +x $folder/bin/kill.sh

echo "[Desktop Entry]" > $folder/byond.desktop
echo "Name=BYOND" >> $folder/byond.desktop
echo "Exec=$folder/bin/byond.exe" >> $folder/byond.desktop
echo "Type=Application" >> $folder/byond.desktop
echo "Categories=Game;" >> $folder/byond.desktop
echo "Terminal=false" >> $folder/byond.desktop

echo "[Desktop Entry]" > $folder/dreamseeker.desktop
echo "Name=Dreamseeker" >> $folder/dreamseeker.desktop
echo "Exec=$folder/bin/dreamseeker.exe %u" >> $folder/dreamseeker.desktop
echo "StartupNotify=false" >> $folder/dreamseeker.desktop
echo "MimeType=x-scheme-handler/byond;" >> $folder/dreamseeker.desktop
