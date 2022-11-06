#!/bin/zsh
# Prepares ISO for packaging

# Add a liveOS user
ROOTPASS="holoconfig"
LIVEOSUSER="liveuser"

echo -e "${ROOTPASS}\n${ROOTPASS}" | passwd root
useradd --create-home ${LIVEOSUSER}
echo -e "${ROOTPASS}\n${ROOTPASS}" | passwd ${LIVEOSUSER}
echo "${LIVEOSUSER} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${LIVEOSUSER}
chmod 0440 /etc/sudoers.d/${LIVEOSUSER}
usermod -a -G rfkill ${LIVEOSUSER}
usermod -a -G wheel ${LIVEOSUSER}
# Begin coreOS bootstrapping below:

# Init pacman keys
pacman-key --init
pacman -Sy

# Install desktop suite
pacman -Rcns --noconfirm pulseaudio xfce4-pulseaudio-plugin pulseaudio-alsa
pacman --overwrite="*" -S holoiso-main holo/filesystem holoiso-updateclient wireplumber flatpak packagekit-qt5 rsync unzip sddm-wayland dkms
wget https://gdrivecdn.thevakhovske.pw/6:/holoiso/os/x86_64/lib32-nvidia-utils-515.57-1-x86_64.pkg.tar.zst -P /etc/holoinstall/post_install/pkgs
pacman -U --noconfirm /etc/holoinstall/post_install/pkgs/lib32-nvidia-utils-515.57-1-x86_64.pkg.tar.zst

# Remove useless shortcuts for now
mv /etc/xdg/autostart/steam.desktop /etc/xdg/autostart/desktopshortcuts.desktop /etc/skel/Desktop/steamos-gamemode.desktop /etc/skel/Desktop/Return.desktop /etc/holoinstall/post_install_shortcuts

# Enable stuff
systemctl enable sddm NetworkManager systemd-timesyncd cups bluetooth sshd

# Download extra stuff
mkdir -p /etc/holoinstall/post_install/pkgs
wget https://gdrivecdn.thevakhovske.pw/6:/holostaging/os/x86_64/linux-holoiso-5.18.1.holoiso20220606.1822-1-x86_64.pkg.tar.zst -P /etc/holoinstall/post_install/pkgs
wget https://gdrivecdn.thevakhovske.pw/6:/holostaging/os/x86_64/linux-holoiso-headers-5.18.1.holoiso20220606.1822-1-x86_64.pkg.tar.zst -P /etc/holoinstall/post_install/pkgs
wget $(pacman -Sp win600-xpad-dkms) -P /etc/holoinstall/post_install/pkgs_addon
wget $(pacman -Sp linux-firmware-neptune) -P /etc/holoinstall/post_install/pkgs_addon

# Workaround mkinitcpio bullshit so that i don't KMS after rebuilding ISO each time and having users reinstalling their fucking OS bullshit every goddamn time.
rm /etc/mkinitcpio.conf
mv /etc/mkinitcpio.conf.pacnew /etc/mkinitcpio.conf 
rm /etc/mkinitcpio.d/* # This removes shitty unasked presets so that this thing can't overwrite it next time
cp /etc/holoinstall/post_install/mkinitcpio_presets/linux-neptune.preset /etc/mkinitcpio.d/ # Yes. I'm lazy to use mkinitcpio-install. Problems? *gigachad posture*

# Prepare thyself
chmod +x /etc/holoinstall/post_install/install_holoiso.sh
chmod +x /etc/skel/Desktop/install.desktop