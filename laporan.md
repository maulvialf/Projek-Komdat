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
CHECK LAGI YA :""
ntar isiin dari sini
https://docs.nodebb.org/installing/os/ubuntu/
***

***
#### Instalasi Node.js
1. Instalasi Node.js melalui terminal
```
$ curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
$ sudo apt-get install -y nodejs
```
#### Menginstall MongoDB
1. Melakukan penginstallan MongoDB pada Ubuntu
```
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
$ echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
$ sudo apt-get update
$ sudo apt-get install -y mongodb-org
```
2. Kemudian, verifikasi versi dari MongoDB. Versi yang terbaru seharusnya 4.0
```
$ mongod --version
db version v4.0
```
3. Memulai service ```mongod``` dan melakukan verifikasi statusnya
```
$ sudo systemctl start mongod
$ sudo systemctl status mongod
```
#### Konfigurasi MongoDB
Administrasi MongoDB dilakukan melalui MongoDB Shell ```mongo```. Instalasi default dari MongoDB mendengarkan port ```27017``` dan dapat diakses secara lokal. 
Pertama, akses shell:
```
$ mongo
```
Mengganti menjadi built-in```admin``` database:
```
> use admin
```
Buat user administratif ( berbeda dengan user ```nodebb``` yang akan dibuat nanti). Ganti isi dari ```<Enter secure password>``` dengan password yang Anda inginkan. Pastikan bahwa ```<``` dan ```>``` tidak tertinggal!
```
> db.createUser( { user: "admin", pwd: "<Enter a secure password>", roles: [ { role: "root", db: "admin" } ] } )
```
User yang telah dibuat akan dimasukan ke dalam ```admin``` database untuk memanajemen MongoDB setelah otorisasi telah di aktifkan.
Untuk membuat database baru yang, gunakan ```use```. Buat database baru bernama ```nodebb```:
```
> use nodebb
```
Database akan terbentuk dan konteks akan berpindah menuju ```nodebb```. Selanjutnya membuat user ```nodebb``` dengan otoritas yang sesuai:
```
> db.createUser( { user: "nodebb", pwd: "<Enter a secure password>", roles: [ { role: "readWrite", db: "nodebb" }, { role: "clusterMonitor", db: "admin" } ] } )
```
```readWrite``` mengizinkan NodeBB untuk menyimpan dan mengambil dari database ```nodebb```.
Sedangkan ```clusterMonitor``` menyediakan hak NodeBB untuk read-only access pada query statistik server database yang nantinya dapat diketahui dalam NodeBB Administrative Control Panel (ACP)
Keluar dari Mongo Shell:
```
> quit()
```
Mengaktifkan otorisasi database dalam fail konfiguras MongoDB ```/etc/mongod.conf``` dengan menambahkan lines berikut:
```
security:
  authorization: enabled
```
Restart MongoDB dan verifikasi user administratif yang telah dibuat sebelumnya, apakah dapat connect:
```
$ sudo systemctl restart mongod
$ mongo -u admin -p your_password --authenticationDatabase=admin
```
Bila semua telah terkonfigurasi dengan baik, maka Mongo Shell akan connect. Keluarlah dari shell.

#### Menginstall NodeBB
Pastikan telah terinstall git. Jika belum, maka install melalui terminal dengan :
```
$ sudo apt-get install -y git
```
Selanjutnya clone NodeBB. Dalam contoh ini, direktori lokal ```nodebb``` yang digunakan, walaupun di mana saja tidak ada masalah.
```
$ git clone -b v1.11.x https://github.com/NodeBB/NodeBB.git nodebb
$ cd nodebb
```
Hal ini, akan melakukan clone repositori NodeBB dari ```v1.11.x``` menuju direktori ```nodebb```.
Kemudian, menginstall modul untuk npm.
```
$ ./nodebb setup
```
Sejumlah pertanyaan akan muncul. Setting default untuk local server listening pada port default ```4567``` dengan MongoDB listening pada port ```27017```. 
Ketika diminta, pastikan untuk mengisi username dan password MongoDB sesuai yang telah dikonfigurasi sebelumnya untuk NodeBB. 
Ketika konektivitas terhadap database telah terkonfirmasi, setup akan memberitahu bahwa penginstallan sedang berjalan.
Karena ini merupakan NodeBB yang masih baru, seorang adminstrator forum harus dibuat. Masukkan informasi administrator yang diinginkan. Ini akan menghasilkan pesan ```NodeBB Setup Complete```.
Akhirnya, dapat menggunakan cli utility untuk memulai NodeBB:
```
$ ./nodebb start

```

#### Menginstall nginx
Untuk menjalankan NodeBB agar dapat disediakan tanpa port, nginx dapat diatur untuk mem-proxy semua permintaan ke hostnmae yang diinginkan menuju ke NodeBB server yang berjalan di 
```
$ sudo apt-get install -y nginx
$ nginx -v
```
Dan service-nya akan berjalan
```
$ sudo systemctl start nginx
$ sudo systemctl status nginx
```

#### Konfigurasi nginx
Berikut adalah contoh commands untuk membuat konfiguras nginx baru:
```
$ cd /etc/nginx/sites-available
$ sudo nano forum.example.com # config entered into file and saved
$ cd ../sites-enabled
$ sudo ln -s ../sites-available/forum.example.com
```
Di bawah ini merupakan contoh konfigurasi untuk NodeBB berjalan pada port ```4567```:
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
Setelah melakukan perubahan pada konfigurasi nginx, harus memuat ulang service agar perubahan dapat terlihat:
```
$ sudo systemctl reload nginx
```

#### Setelah Instalasi
Sekarang NodeBB telah terinstall dan berjalan. Seharusnya dapat mengakses ```http://forum.example.com``` dan berinteraksi dengan forum.

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

1. Nonaktifkan Forum
Update dapat dilakukan selagi forum aktif. Namun, direkomendasikan untuk menonaktifkan forum untuk Update

```
$ cd /path/to/nodebb
$ ./nodebb stop
```

2. Backup Data
Selanjutnya, lakukan backup data Redis ```.rdb```. Database utama Redis tersimpan di ```/var/lib/redis/dump.rdb```.

Setelah itu, lakukan back up pada MongoDB yang didahului dengan mematikan MongoDB ```sudo service mongodb stop```.
Jalankan ```mongodump``` untuk mem-backup MongoDB. Perintah tersebut akan membuat struktur direktori yang bisa di-restore.

Backup selanjutnya dilakukan pada Avatar
```
$ cd /path/to/nodebb/public
$ tar -czf ~/nodebb_assets.tar.gz ./uploads
```

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
https://www.slant.co/versus/2789/2791/~discourse_vs_nodebb
https://community.nodebb.org/topic/10827/why-i-chose-to-use-nodebb-over-phpbb-discourse-mybb-and-other-forums
https://www.reddit.com/r/webdev/comments/415nlp/discourse_flarum_nodebb_oh_my/
