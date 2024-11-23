folder=$(dirname "$(realpath "$0")")
prefix=$folder/.wine32

export WINEARCH=win32
export WINEPREFIX=$prefix
export WINEESYNC=1
export WINE_D3D_CONFIG="renderer=vulkan;VideoPciVendorID=0xc0de"

winetricks -q "$folder/byond.verb"

byond=$folder/.wine32/drive_c/Program\ Files/BYOND

ln -sf "$byond/help" $folder

mkdir -p "$folder/bin"
for program in "$byond"/bin/*.exe; do
    output="$folder/bin/$(basename "$program")"
    echo "#!/bin/bash" > $output
    echo "export WINEPREFIX=\"$prefix\"" >> $output
    echo "export WINEARCH=\"$WINEARCH\"" >> $output
    echo "export WINE_D3D_CONFIG=\"$WINE_D3D_CONFIG\"" >> $output
    echo "export WINEDEBUG=-all" >> $output
    echo "export WINE_LARGE_ADDRESS_AWARE=1" >> $output
    echo "export WINEESYNC=$WINEESYNC" >> $output

    echo "trap 'kill %1' SIGINT" >> $output
    echo "wine \"$program\" \"\$@\"" >> $output
    chmod +x $output
done

ln -sf "$byond/bin/"*.dll "$folder/bin"

desktop="$folder/byond-byond.desktop"
echo "[Desktop Entry]" > $desktop
echo "Name=BYOND" >> $desktop
echo "Exec=$folder/bin/byond.exe" >> $desktop
echo "Type=Application" >> $desktop
echo "Categories=Game;" >> $desktop
echo "Terminal=false" >> $desktop

dreamseeker="$folder/byond-dreamseeker.desktop"
echo "[Desktop Entry]" > $dreamseeker
echo "Name=Dreamseeker" >> $dreamseeker
echo "Exec=$folder/bin/dreamseeker.exe %u" >> $dreamseeker
echo "Type=Application" >> $dreamseeker
echo "Categories=Game;" >> $dreamseeker
echo "StartupNotify=false" >> $dreamseeker
echo "MimeType=x-scheme-handler/byond;" >> $dreamseeker

if command -v 7z >/dev/null 2>&1; then
    7z e "$byond/bin/byond.exe" ".rsrc/1033/ICON/7.ico"
    mv 7.ico "$folder/icon.ico"

    echo "Icon=$folder/icon.ico" >> $desktop
    echo "Icon=$folder/icon.ico" >> $dreamseeker
fi

xdg-desktop-menu install $desktop
xdg-desktop-menu install $dreamseeker
xdg-mime default dreamseeker.desktop x-scheme-handler/byond
