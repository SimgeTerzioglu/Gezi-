# Gezi Uygulaması
Bu uygulamanın temel amacı Antalya şehrini gezecek birisine şehri tanıtmak ve bir nevi rehber görevi sağlamaktır.
Kullanıcılar kayıt olmadan/giriş yapmadan uygulamayı kullanamazlar.
 * Kullanıcılar kayıt esnasında,
    * E-posta
    * Kullanıcı adı / nickname (yorumlarda gösterilmek üzere)
    * Şifre
   sağlamak zorundadırlar. Aksi takdirde kayıt işlemi gerçekleşmez. Kullanıcılar kayıttan sonra uygulamaya yönlendirilirler. Çıkış yaptıktan sonra tekrardan e-posta ve şifreleri ile giriş yapabilirler.
İlgili gifler:
![](kayit)
![](giris)

# Kategoriler
Uygulamada 7 temel kategori ve bir de "Favoriler" bulunur. Bu kategoriler:
 * Parklar
 * Kütüphaneler
 * Tarihi Yerler
 * Oteller
 * Marketler
 * İbadet Yerleri
 * Otoparklar
 Şeklindedir. Her Kategoriye tıklandığında ilgili yerler listelenir:
İlgili gifler:
![](Kategoriler)
# Bilgi Ekranları
Her kategoriden bir yer seçildiğinde o yer hakkında resim, genel bilgi, ücret, açık olduğu saatler ve puanları gösterilir:
![](yer örnekleri)
# Yorum Ve Puanlama
Kullanıcılar önceki kullanıcıların yorumlarını görebilir, yeni yorumlar ekleyebilir ve 1-5 uzerinden yerleri değerlendirebilirler.
Örnek olarak yorum ekleme ve yorum görüntüleme şu şekildedir:
![](yorum)
Puanlama kısmında kısmında ise kullanıcıların bir önceki yaptığı puanlamalar da değerlendirilir. Örnek olarak Köprülü Kanyon Milli parkını bir kişi daha önceden değerlendirmiş ve 3 puan vermiştir. Kullanıcımız ise 4 puan vererek parkın puanını 3.5'a (3+4/2=3.5) çıkartmıştır. Puan 4'ün altında olduğu için deneme123 kullanıcısının favorilerinde Köprülü Kanyon bulunmamaktadır.
![](daha önceden puanlanmış)
Tüm bu işlemlerin yeni bir kullanıcı ile yapılışı ise aşağıdaki gibidir. Yeni kullanıcının puanı ile Köprülü Kanyon'un puanı 4'e (3+4+5/3=4) çıkmış ve yeni kullanıcının favoriler ekranında gözükmektedir.
![](yeni kullanıcı puan güncellemesi)
 * Uygulamamızın genel akışı yukarıdaki giflerde görüldüğü şekildedir.
 Uygulamamızı yaparken Flutter ve Firebase kullandık. Sqflite yerine Firebase kullanmamızın ana sebebi web üzerinden veritabanımızı rahatlıkla kontrol edebiliyor oluşumuzdur. Ayrıca yerler ile alakalı resim vs. çekmek için website linkini koymamız yeterli oluyor. Herhangi bir verinin yanlış/hatalı/eksik girilmesi ya da uygulama üzerinden düzgün okunamaması durumlarına karşın web üzerinden rahatlıkla veritabanımızı düzenleyip veri ekleme/silme/güncelleme yapabiliyoruz. Bunlar için uzun uzun SQL sorguları yazmamıza gerek kalmıyordu. Biz de tercihimizi Firebase'den yana kullandık. Bunun için basitçe bir Google hesabı açıp Firebase sitesinden veritabanını ayarlayıp uygulamamıza gerekli kütüphaneleri import etmek ve gerekli dosyalarda (pubspec.yaml vs.) eklemeleri yapmak yeterli oldu.
 Uygulamamızda kullandığımız veritabanı ve içeriği de aşağıdaki ekran görüntülerinde olduğu gibidir:
 ![](firebase genel)
 * Yerler ve hakkında tutulan veriler:
 ![]( firebase puanlama)
 * Yorumlar ve hakkında tutulan veriler:
 ![](firebase yorumlar)
 * Kullanıcılar ve hakkında tutulan veriler:
 ![](firebase kullanıcılar)
 ***
 # Hazırlayanlar:
 * Zehra Akgül - 1190505069
 * Simge Terzioğlu - 1190505072
 * Melike Sağır - 1190505019
 * Aylin Işık - 5190505044
