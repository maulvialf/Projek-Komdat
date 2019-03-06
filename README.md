<img alt="" class=" forum-logo" src="http://nodebb.org/assets/uploads/system/site-logo.png?v=6tanq3ld65i">

<h1 style="font-size: 70px;" align = center >NodeBB</h1>

## Daftar Isi
- [Daftar Isi](#daftar-isi)
- [Sekilas Tentang](#sekilas-tentang)
- [Instalasi](#instalasi)
  * [Requirements](#requirements)
  * [Persiapan](#persiapan)
  * [Langkah Langkah Instalasi](#langkah-langkah-instalasi)
    + [Instalasi Node.js](#instalasi-nodejs)
    + [Menginstall MongoDB](#menginstall-mongodb)
    + [Konfigurasi MongoDB](#konfigurasi-mongodb)
    + [Menginstall NodeBB](#menginstall-nodebb)
    + [Menginstall nginx](#menginstall-nginx)
    + [Konfigurasi nginx](#konfigurasi-nginx)
    + [Setelah Instalasi](#setelah-instalasi)
- [Maintenance](#maintenance)
  * [Update](#update)
    + [Nonaktifkan Forum](#nonaktifkan-forum)
    + [Backup Data](#backup-data)
    + [Mengambil kode terbaru](#mengambil-kode-terbaru)
    + [Menjalankan skrip upgrade NodeBB](#menjalankan-skrip-upgrade-nodebb)
- [Otomatisasi](#otomatisasi)
  * [Instalasi & Konfigurasi](#instalasi---konfigurasi)
- [Cara Pemakaian](#cara-pemakaian)
  * [Membuat akun](#membuat-akun)
  * [Membuat postingan](#membuat-postingan)
  * [Mereply](#mereply)
  * [Melakukan Chat](#melakukan-chat)
  * [Dashboard Admin](#dashboard-admin)
  * [Mengganti tema](#mengganti-tema)
- [Pembahasan](#pembahasan)
  * [Pendapat anda tentang aplikasi web ini](#pendapat-anda-tentang-aplikasi-web-ini)
  * [Bandingkan dengan aplikasi web kelompok lain yang sejenis](#bandingkan-dengan-aplikasi-web-kelompok-lain-yang-sejenis)
- [Referensi](#referensi)

## Sekilas Tentang

NodeBB adalah aplikasi komunitas berbasis forum web. NodeBB berbasis pada NodeJS dan dibuat dengan sistem caching redis dan database MongoDB. NodeBB memiliki banyak fitur seperti notifikasi realtime dan interaksi langsung.

## Instalasi

### Requirements

Untuk menginstall NodeBB diperlukan aplikasi berikut yang harus diinstall
- Node.JS versi 6 keatas.
- Redis versi 6.8.9 atau lebih atau MongoDB versi 6.6 atau lebih sebagai database dari aplikasi ini
- Nginx versi 1.3.13 keatas sebagai proxy forwarder agar setiap aplikasi yang diakses domain NodeBB pada port 80 akan mengakses NodeBB

### Persiapan

Pada laporan ini kami menggunakan operating sistem Ubuntu Server 18.04 pada Virtual Box dan juga Docker untuk melakukan otomasi untuk menginstall pada komputer host. 

### Langkah Langkah Instalasi

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
Sejumlah pertanyaan akan muncul. Setting default untuk local server listening pada port default ```8000``` dengan MongoDB listening pada port ```27017```. 
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
Di bawah ini merupakan contoh konfigurasi untuk NodeBB berjalan pada port ```8000```:
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

        proxy_pass http://127.0.0.1:8000;
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

Berikut adalah hasil log dari `./nodebb log`. Terlihat program melisten pada port tersebut.
<h1 align='center'>
<a href="http://i.imgur.com/hTLEniQ.png">
  <img src="http://i.imgur.com/hTLEniQ.png" />
</a>
</h1>

Buka pada browser http://0.0.0.0:8000. Jika berhasil. Selamat anda telah berhasil menginstall NodeBB
<h1 align='center'>
<a href="http://i.imgur.com/GnnQK0H.png">
  <img src="http://imgur.com/GnnQK0Hl.png" />
</a>
</h1>

Sekarang NodeBB telah terinstall dan berjalan. Seharusnya dapat mengakses ```http://0.0.0.0:8000``` dan berinteraksi dengan forum.

##  Maintenance

#### Nonaktifkan Forum
Update dapat dilakukan selagi forum aktif. Namun, direkomendasikan untuk menonaktifkan forum untuk Update

```
$ cd /path/to/nodebb
$ ./nodebb stop
```

#### Backup Data
Selanjutnya, lakukan backup data. Jika Anda menggunakan Redis, pindahkan database utama Redis yang tersimpan di ```/var/lib/redis/dump.rdb``` ke tempat lain yang aman. Database Redis berekstensi ```.rdb```.

Jika menggunakan MongoDB, lakukan back up dimulai dengan mematikan MongoDB

```
sudo service mongodb stop
```

Jalankan ```mongodump``` untuk mem-backup MongoDB. Perintah tersebut akan membuat struktur direktori yang bisa di-restore.

Backup selanjutnya dilakukan pada Avatar
```
$ cd /path/to/nodebb/public
$ tar -czf ~/nodebb_assets.tar.gz ./uploads
```

#### Mengambil kode terbaru

Untuk naik ke versi yang lebih tinggi, misal: v0.2 ke v0.4.3
```
$ git fetch
$ git checkout v0.4.x
$ git merge origin/v0.4.x
```

Untuk naik ke versi yang masih satu branch, misal: v0.2.1 ke v0.2.2
```
$ git fetch
$ git reset --hard origin/v0.2.x
```

#### Menjalankan skrip upgrade NodeBB
Untuk NodeBB v0.3.0 ke atas, jalankan perintah berikut:
```
$ ./nodebb upgrade
```

Jika upgrade berhasil, jalankan kembali NodeBB. NodeBB yang dijalankan adalah versi terbaru.

## Otomatisasi

### Instalasi & Konfigurasi

Untuk melakukan otomasi pada penginstalan nodebb, terdapat docker-compose file pada dokumentasi program. Keuntungan dengan menggunakan docker adalah penginstalan dapat dilakukan dengan scripting dan apabila terdapat bug pada nodebb tidak akan mempengaruhi server karena berada dalam image sendiri.

Untuk menggunakan docker terlebih dahulu install docker pada server
```
sudo apt install docker -y
```

Masuk kedalam directory docker_nodebb
```
cd docker_nodebb
```

Isikan pada nodebb.env dengan konfigurasi dari nodebb yang kita inginkan
```
# agar bisa diakses secara remot
NODEBB_URL=http://0.0.0.0
NODEBB_PORT=8000
NODEBB_SECRET=asupersecret
NODEBB_PLUGINLIST=
NODEBB_WEBSOCKETONLY=false
MONGO_HOST=mongo
MONGO_PORT=27017
MONGO_USERNAME=nodebb
MONGO_PASSWORD=nodebb
MONGO_DATABASE=nodebb
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin123
ADMIN_EMAIL=maulvi_alfansuri@apps.ipb.ac.id
SSMTP_DOMAIN=smtp.gmail.com
SSMTP_EMAIL=maulvi_alfansuri@apps.ipb.ac.id
SSMTP_HOST=smtp.gmail.com
SSMTP_PORT=465
SSMTP_PASSWORD=****
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
S3_UPLOADS_BUCKET=
S3_UPLOADS_HOST=
```

Jika konfigurasi sudah diisi. Run docker dengan perintah
```
docker-compose up
```
<h1 align='center'>
<a href="http://i.imgur.com/jg0obbO.png">
  <img src="http://imgur.com/jg0obbOl.png" />
</a>
</h1>

Jika mongo db sudah dimiliki diluar docker, anda dapat menggunakan mongo db luar tanpa harus menginstall mongoddb didalam docker. Ini berguna apabila ingin menggunakan database lama untuk migrasi perangkat ke dalam docker
```
sudo docker run --env-file=./nodebb.env -ti digitallumberjack/docker-nodebb:latest
```

## Cara Pemakaian

### Membuat akun
Untuk membuat akun. Tinggal mengklik register dan mengisikan form
<h1 align='center'>
<a href="http://i.imgur.com/j7qtnZM.png">
  <img src="http://imgur.com/j7qtnZMl.png" />
</a>
</h1>

### Membuat postingan
<h1 align='center'>
<a href="http://i.imgur.com/Yai1h5o.png">
  <img src="http://imgur.com/Yai1h5ol.png" />
</a>
</h1>

Hasil postingan
<h1 align='center'>
<a href="http://i.imgur.com/T1YzhRU.png">
  <img src="http://imgur.com/T1YzhRUl.png" />
</a>
</h1>

### Mereply
<h1 align='center'>
<a href="http://i.imgur.com/sf2lTAQ.png">
  <img src="http://imgur.com/sf2lTAQl.png" />
</a>
</h1>

<h1 align='center'>
<a href="http://i.imgur.com/0wd7tsf.png">
  <img src="http://imgur.com/0wd7tsfl.png" />
</a>
</h1>

### Melakukan Chat
<h1 align='center'>
<a href="http://i.imgur.com/xwpntgW.png">
  <img src="http://imgur.com/xwpntgWl.png" />
</a>
</h1>
<h1 align='center'>
<a href="http://i.imgur.com/4cI3JIh.png">
  <img src="http://imgur.com/4cI3JIhl.png" />
</a>
</h1>

### Dashboard Admin
<h1 align='center'>
<a href="http://i.imgur.com/d4vtMWY.png">
  <img src="http://imgur.com/d4vtMWYl.png" />
</a>

### Mengganti tema
<h1 align='center'>
<a href="http://i.imgur.com/r7CV4WW.png">
  <img src="http://imgur.com/r7CV4WWl.png" />
</a>
</h1>

<h1 align='center'>
<a href="http://i.imgur.com/KLmlRz5.png">
  <img src="http://imgur.com/KLmlRz5l.png" />
</a>
</h1>

## Pembahasan

### Pendapat anda tentang aplikasi web ini

- pros:
  1. Integrasi sosial yang mudah, dengan node bb pengguna dapat dengan mudah membagikan konten dengan social media seperti facebook atau twitter. Sehingga mempermudah memperkenalkan dan mempublikasikan forum disocial media yang diinginkan.
  2. Optimalisasi yang fleksibel, dengan menggunakan nodebb forum secara otomatis akan dioptimalkan _mobile view_ sehingga forum dapat diakses dimana saja, kapan saja, dengan segala device.
  3. Nodebb juga dapat menerjemahkan forum  hingga dengan 50 bahasa, sehingga forum dapat menjangkau seluruh dunia tanpa batasan bahasa.
  4. Dengan Nodebb forum juga dapat mencantumkan file media seperti foto, video, dan rekaman suara. Sehingga post didalam forum dapat menjadi jauh lebih menarik.
	
- cons:
  1. Harga yang termasuk mahal, hosting menggunakan nodebb tidak terbilang murah. _Open source version_ menuntut pengguna untuk memahami program tersebut atau _Not user friendly_ .
  2. Tidak ada pengembalian, sehingga bila tidak menjadi hosting uang yang telah diberikan tidak akan dikembalikan kepada client

### Bandingkan dengan aplikasi web kelompok lain yang sejenis
  Perbandingan Nodebb dengan discourse
  1. Untuk kemudahan penginstalan dan penggunaan Nodebb lebih unggul dibandingkan discourse dikarenakan penginstalan discourse menuntut pengguna telah memahami pengetahuan tentang server. Sedangkan dengan nodebb penginstalan tidak menuntut pengetahuan server semendalam saat menginstall discourse.
  2. Discourse tidak memiliki _free version_ sehingga jika ingin menggunakan discourse pengguna harus membeli terlebih dahulu, sedangkan nodebb memiliki _free version_ sehingga kita dapat mencoba terlebih dahulu apakah cocok atau tidak.
  3. Nodebb memiliki fitur live chat, sedangkan discourse tidak. Sehingga dengan menggunakan nodebb forum akan menjadi lebih menarik dan interaktif.
  4. Nodebb mempermudah pengguna untuk menghubungkan forum/post pengguna dengan social media sehingga lebih menarik untuk ditelusuri.
  5. Memiliki server diberbagai lokasi, sehingga lebih mudah diakses oleh para pengguna.


## Referensi

Cantumkan tiap sumber informasi yang anda pakai.
- <https://docs.nodebb.org/installing/os/ubuntu/> - nodeBB Installation
- <https://nodebb.org/> - nodeBB official
- <https://github.com/NodeBB/NodeBB> - nodeBB github source
- <https://www.howtoforge.com/how-to-install-nodebb-forum-on-ubuntu-1804-lts/> - nodeBB Installation
- <https://www.slant.co/versus/2789/2791/~discourse_vs_nodebb> - nodeBB vs discourse comparison
- <https://community.nodebb.org/topic/10827/why-i-chose-to-use-nodebb-over-phpbb-discourse-mybb-and-other-forums> - nodeBB vs discourse comparison
- <https://www.reddit.com/r/webdev/comments/415nlp/discourse_flarum_nodebb_oh_my/> - nodeBB vs discourse comparison on reddit
- <https://www.comparakeet.com/forum-software/nodebb-review/> - nodeBB review
- <https://github.com/digitalLumberjack/docker-nodebb/> - nodeBB docker github
- <https://gitlab.com/recalbox/ops/nodebb> - nodeBB docker gitlab
