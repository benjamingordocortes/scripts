#!/bin/bash
#autor benjamingordocortes
#actualizacion de los repositorios

instalacion_lamp(){
    #instalacion servicio apache
    apt install apache2 -y
    #instalacion de php y creacion del archivo info.php
    sudo apt install php -y
    sudo echo '<?php phpinfo(); ?>' > /var/www/html/info.php
    #instalacion de mariadb
    sudo apt install -y mariadb-server
}
configuracion_lamp(){
    #configurar phpmyadmin para usuario root
    echo 'contraseña para el usuario root en mysql y phpmyadmin'
    read passwd
    #configuracion en mariadb para poder inicar sesision con el usuario root
    sudo mysql -u root -e "use mysql;update user set password=PASSWORD('$passwd') where User='root';update user set plugin='' where User='root';flush privileges;"
}
instalacion_vsftpd(){
    #instalar programa vsftpd para tener el servicio ftp
    sudo apt install vsftpd -y
}
configuracion_user_ftp(){
    #peticion de nombre de usuario y contraseña para el ftp
    echo 'Pon un nombre de usuario para el servicio ftp'
    read usuarioftp
    echo "contraseña para el usuario: "$usuarioftp
    read passwdftp
    #crear usuario
    useradd $usuarioftp
    #contraseña usuario
    echo $usuarioftp:$passwdftp | chpasswd
    #crear directorio
    mkdir /home/$usuarioftp
    #modificamos usuario
    sudo usermod $usuarioftp -d /home/$usuarioftp -s /bin/bash -G $usuarioftp
    #cambiar grupo y dueño del directorio usuarioftp
    sudo chown $usuarioftp:$usuarioftp /home/$usuarioftp
    #crear enlace simbolico para ftp
    ln -s /var/www  /home/$usuarioftp/www
    #cambiar permisos del directorio
    chown $usuarioftp:$usuarioftp -R /home/$usuarioftp/
    #crear carpetas y añadir permisos al usuario
    mkdir /home/$usuarioftp/www/css
    chown $usuarioftp:$usuarioftp -R /home/$usuarioftp/www/css
    chown $usuarioftp:$usuarioftp -R /home/$usuarioftp/www/html
    #crear archivo para añadir usuario que tengan acceso al servicio
    echo "$usuarioftp" > /etc/vsftpd.chroot_list
}
configuracion_vsftpd(){
    #copia de seguridad y eliminar el archivo de configuracion vsftpd para sustituirlo por otro
    cp /etc/vsftpd.conf /etc/vsftpdbak.conf
    rm /etc/vsftpd.conf
    #acceder al archivo de configuracion de vsftpd y añadir las ordenes
    echo "listen=NO" > /etc/vsftpd.conf
    echo "write_enable=YES" >> /etc/vsftpd.conf
    echo "listen_ipv6=YES" >> /etc/vsftpd.conf
    echo "anonymous_enable=NO" >> /etc/vsftpd.conf
    echo "local_enable=YES" >> /etc/vsftpd.conf
    echo "dirmessage_enable=YES" >> /etc/vsftpd.conf
    echo "use_localtime=YES" >> /etc/vsftpd.conf
    echo "xferlog_enable=YES" >> /etc/vsftpd.conf
    echo "connect_from_port_20=YES" >> /etc/vsftpd.conf
    echo "chroot_local_user=YES" >> /etc/vsftpd.conf
    echo "allow_writeable_chroot=YES" >> /etc/vsftpd.conf
    echo "chroot_list_enable=YES" >> /etc/vsftpd.conf
    echo "chroot_list_file=/etc/vsftpd.chroot_list" >> /etc/vsftpd.conf
    echo "secure_chroot_dir=/var/run/vsftpd/empty" >> /etc/vsftpd.conf
    echo "pam_service_name=vsftpd" >> /etc/vsftpd.conf
    echo "rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem" >> /etc/vsftpd.conf
    echo "rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key" >> /etc/vsftpd.conf
    echo "ssl_enable=YES" >> /etc/vsftpd.conf
    #reinciar servicio para aplicar cambios
    sudo service vsftpd restart
}
instalacion_phpmyadmin(){
    #instalacion de phpmyadmin
    #seleccionaremos la contraseña deseada para el usuario phpmyadmin y el servidor apache2
    #cuando de el fallo dar a ignorar. Para acceder al phpmyadmin usuario root y la contraseña
    #de mysql puesta anteriormente
    apt install -y phpmyadmin
}

if [ "$(whoami)" = "root" ]; then
    sudo apt update
    clear
    echo "#############################################################################"
    echo "################################ LAMP #######################################"
    echo "#############################################################################"
    echo "Pulsa enter para empezar:"
    read  pausaphp
    instalacion_lamp
    configuracion_lamp
    clear
    echo "#############################################################################"
    echo "################################ FTP ########################################"
    echo "#############################################################################"
    echo "Pulsa enter para comenzar:"
    read  pausaftp
    instalacion_vsftpd
    configuracion_user_ftp
    configuracion_vsftpd
    clear
    echo "#############################################################################"
    echo "############################## PHPMYADMIN ###################################"
    echo "#############################################################################"
    echo "Pulsa enter para comenzar:"
    read  pausaphpmyadmin
    instalacion_phpmyadmin
    clear
    echo "#############################################################################"
    echo "########################### PROGRAMA FINALIZADO #############################"
    echo "#############################################################################"
    echo "Pulsa enter para salir:"
    read  exit
    clear
else
    echo "no eres root, no puedes iniciar este script"
fi
