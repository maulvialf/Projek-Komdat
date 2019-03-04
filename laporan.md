# Aplikasi Forum berbasis Web NodeBB dengan teknologi NodeJS


## Sekilas Tentang

NodeBB adalah aplikasi komunitas berbasis forum web. NodeBB berbasis pada NodeJS dan dibuat dengan sistem caching redis dan database MongoDB. NodeBB memiliki banyak fitur seperti notifikasi realtime dan interaksi langsung.

## Instalasi

### Requirements

Untuk menginstall NodeBB diperlukan aplikasi berikut yang harus diinstall
- Node.JS versi 6 keatas.
- Redis versi 6.8.9 atau lebih atau MongoDB versi 6.6 atau lebih sebagai database dari aplikasi ini
- Nginx versi 1.3.13 keatas sebagai proxy forwarder agar setiap aplikasi yang diakses domain NodeBB pada port 80 akan mengakses NodeBB

### Persiapan

Pada laporan ini kami menggunakan operating sistem Ubuntu Server 18.04 pada Virtual Box.

### Langkah Langkah Instalasi
***
ntar isiin dari sini
https://docs.nodebb.org/installing/os/ubuntu/
***

***
- Menginstall Node.JS melalui terminal
```
$ curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
$ sudo apt-get install -y nodejs
```
### Menginstall MongoDB
- Pertama menggunakan line ini
```
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
$ echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
$ sudo apt-get update
$ sudo apt-get install -y mongodb-org
```

- Menjalankan service mongod dan memverifikasi statusnya
```
$ sudo systemctl start mongod
$ sudo systemctl status mongod
```

- Melakukan konfigurasi MongoDB. Secara default, MongoDB listening pada port 27017 dan dapat diakses secara lokal.
```
$ mongo
> use admin
> db.createUser( { user: "admin", pwd: "<Enter a secure password>", roles: [ { role: "root", db: "admin" } ] } )
> use nodebb
> db.createUser( { user: "nodebb", pwd: "<Enter a secure password>", roles: [ { role: "readWrite", db: "nodebb" }, { role: "clusterMonitor", db: "admin" } ] } )
> quit()
```
	
- Mengaktifkan otorisasi database dalam fail konfiguras MongoDB /etc/mongod.conf dengan menambahkan 
```
security:
  authorization: enabled
```

- Restart MongoDB dan verifikasi user administratif yang dibuat sebelumnya apakah dapat connect
```
$ sudo systemctl restart mongod
$ mongo -u admin -p your_password --authenticationDatabase=admin
```

### Menginstall NodeBB
- Menginstall git jika belum
```
$ sudo apt-get install -y git
```
- Selanjutnya clone NodeBB. Disini, direktori lokal nodebb digunakan, walaupun dimana saja tidak apa-apa.
```
$ git clone -b v1.11.x https://github.com/NodeBB/NodeBB.git nodebb
$ cd nodebb
```
- Menginstall modul untuk npm.
```
$ ./nodebb setup
```
- Menjalankan NodeBB
```
$ ./nodebb start

```

### Menginstall nginx
```
$ sudo apt-get install -y nginx
$ sudo systemctl start nginx
$ sudo systemctl status nginx
```

### Konfigurasi nginx
- Berikut adalah contoh commands untuk membuat config nginx baru:
```
$ cd /etc/nginx/sites-available
$ sudo nano forum.example.com # config entered into file and saved
$ cd ../sites-enabled
$ sudo ln -s ../sites-available/forum.example.com
```

- Di bawah ini merupakan contoh konfigurasi untuk NodeBB berjalan pada port 4567
```
server {
    listen 80;

    server_name forum.example.com;

    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;

        proxy_pass http://127.0.0.1:4567;
        proxy_redirect off;

        # Socket.IO Support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

- Setelah itu, mereload service agar perubahan dapat terlihat
```
$ sudo systemctl reload nginx
```
***


## Konfigurasi (opsional)

Setting tambahan yang diperlukan untuk meningkatkan fungsi dan kinerja aplikasi, misalnya:
- batas upload file
- batas memori
- etc.

Plugin untuk fungsi tambahan
- single log-on
- etc.


##  Maintenance

### Update
***
ntar isiin dari sini
https://docs.nodebb.org/configuring/upgrade/
***


## Otomatisasi

Skrip shell untuk otomatisasi instalasi, konfigurasi, dan maintenance.


## Cara Pemakaian

- Tampilan aplikasi web
- Fungsi-fungsi utama
- Isi dengan data real/dummy (jangan kosongan) dan sertakan beberapa screenshot


## Pembahasan

- Pendapat anda tentang aplikasi web ini
	- pros:
	- cons:
- Bandingkan dengan aplikasi web kelompok lain yang sejenis


## Referensi

Cantumkan tiap sumber informasi yang anda pakai.
https://docs.nodebb.org/installing/os/ubuntu/
https://nodebb.org/
https://github.com/NodeBB/NodeBB
https://www.howtoforge.com/how-to-install-nodebb-forum-on-ubuntu-1804-lts/
