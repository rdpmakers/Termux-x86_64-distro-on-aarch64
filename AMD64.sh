#!/data/data/com.termux/files/usr/bin/bash

ARCHITECTURE=$(dpkg --print-architecture)

#clear
clear 

#Adding colors
R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

#Warning
echo ${R}"Warning!
Error may occur during installation.
Also, the distro speed will be more lower than proot as it is in QEMU."
sleep 3
clear

#requirements
echo ${G}"Installing requirements"${W}
pkg install proot wget -y
clear
termux-setup-storage
clear

#Notice
echo ${G}"Downloading requirements for QEMU...."${W} ;
wget https://github.com/AllPlatform/Termux-UbuntuX86_64/raw/master/arm64/qemu-x86_64-static;
chmod 777 qemu-x86_64-static;
mv qemu-x86_64-static ~/../usr/bin ;;

#Links
URL="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-minirootfs-3.21.2-x86_64.tar.gz"
ds_name="alpine"
and your distro name is $ds_name "${W}
sleep 2

folder=$ds_name-x64-fs
if [ -d "$folder" ]; then
        ans="y"
        if [[ "$ans" =~ ^([yY])$ ]]; then
                echo ${W}"Deleting existing directory...."${W}
                rm -rf ~/$folder
                rm -rf ~/$ds_name-x64.sh
                sleep 2
        elif [[ "$ans" =~ ^([nN])$ ]]; then
        echo ${R}"Sorry, but we cannot complete the installation"
        exit
        else 
        echo " "
        fi
else 
mkdir -p $folder
fi

#Downloading and decompressing rootfs
clear
echo ${G}"Downloading Rootfs....."${W}
wget $URL -P ~/$folder/ 
echo ${G}"Decompressing Rootfs....."
proot --link2symlink \
    tar -xpf ~/$folder/*.tar.* -C ~/$folder/ --exclude='dev'||:
if [[ ! -d "$folder/etc" ]]; then
     mv $folder/*/* $folder/
fi
echo "127.0.0.1 localhost" > ~/$folder/etc/hosts
rm -rf ~/$folder/etc/resolv.conf
echo "nameserver 8.8.8.8" > ~/$folder/etc/resolv.conf
echo -e "#!/bin/sh\nexit" > "$folder/usr/bin/groups"
mkdir -p $folder/binds

bin=$ds_name-x64.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder -q qemu-x86_64-static"
command+=" -b /dev"
command+=" -b /proc"
command+=" -b $folder/root:/dev/shm"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
#command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/su"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
echo "removing image for some space"
rm -rf $folder/*.tar.*
echo "You can now launch your distro with the 'bash $bin' script"
