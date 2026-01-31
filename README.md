 The Economics of Career: A Multidimensional Wage Analysis (2003-2009)
"Education is not just a degree; it represents the difference between a wage ceiling and a wage floor."

Proje Hakkında (Project Overview)
Bu proje, 2003-2009 yılları arasındaki kritik ekonomik dönemde, ABD'nin Orta-Atlantik bölgesindeki iş gücü piyasasını analiz eden kapsamlı bir Veri Bilimi çalışmasıdır.

ISLR kütüphanesindeki Wage veri seti kullanılarak yapılan bu analizde, sadece maaş rakamlarına odaklanılmamış; Eğitim, Irk, Medeni Durum ve Sektörel Değişimlerin (Sanayi vs. Bilgi Ekonomisi) bireylerin geliri ve sosyal güvencesi üzerindeki etkisi sosyolojik ve ekonomik teoriler ışığında incelenmiştir.

Amaç, veriyi görselleştirmenin ötesine geçip, ardındaki insan hikayesini ve piyasa dinamiklerini ortaya çıkarmaktır.

 Veri Seti ve Kapsam (Dataset & Scope)
Kaynak: ISLR R Paketi (Introduction to Statistical Learning)

Gözlem Sayısı: 3000 Çalışan

Zaman Aralığı: 2003 - 2009 (2008 Finansal Krizi dönemini kapsar)

Önemli Not: Veri seti sadece erkek (male) çalışanlardan oluşmaktadır. Bu nedenle analiz, "Erkek İş Gücü Piyasası" dinamikleri üzerine kurgulanmıştır.

Veri Temizliği: Analiz öncesinde veri setindeki mükerrer (duplicate) kayıtlar temizlenerek istatistiksel tutarlılık sağlanmıştır.

🛠️ Kullanılan Teknolojiler (Tech Stack)
Dil: R Programming

Kütüphaneler:

ggplot2 (İleri seviye veri görselleştirme)

dplyr (Veri manipülasyonu)

ISLR (Veri kaynağı)

viridis (Akademik renk paletleri)

Teknikler:

Keşifçi Veri Analizi (EDA)

K-Means Clustering (Gözetimsiz Öğrenme)

Korelasyon Analizi

İstatistiksel Görselleştirme (Violin Plots, Stacked Bars, Smooth Lines)

 Temel Bulgular ve Analizler (Key Insights)
1. Eğitimin Getirisi: Tavan vs. Taban Etkisi (ROI Analysis)
Analizlerimiz gösteriyor ki, Lise Mezunları kariyerlerine hızlı başlasa da 40 yaşında bir "Maaş Tavanına" (Wage Ceiling) çarpmaktadır. Buna karşın Advanced Degree (Yüksek Lisans/Doktora) sahipleri için maaş artışı çok daha dik bir ivmeyle devam etmekte ve yaşlandıkça gelir makası açılmaktadır.

Insight: Eğitim sadece geliri artırmaz, gelirin varyansını (potansiyelini) genişletir.

2. Bilgi Ekonomisi ve Asyalı İş Gücü (The Asian Anomaly)
Demografik analizlerde, Asyalı (Asian) grubunun eğitim seviyesi arttıkça maaşlarında diğer gruplara göre (özellikle Beyazlar ile kıyaslandığında) çok daha keskin bir artış gözlemlenmiştir.

Insight: Bu durum, Asyalı profesyonellerin ABD'nin sanayiden Knowledge Economy'ye (Bilgi Ekonomisi) geçiş sürecinde yüksek nitelikli (STEM) alanları domine etmesiyle açıklanabilir.

3. Maaş ve Sigorta İlişkisi (The Security Gap)
Sağlık sigortası sahipliği ile maaş arasında doğrudan bir korelasyon tespit edilmiştir. Yıllık 110k$ bandını aşan çalışanlarda sigortasızlık oranı neredeyse sıfıra inerken, <70k$ bandında çalışanların büyük kısmı sigortasızdır.

Insight: Sağlık sigortası sadece bir yan hak değil, işin niteliğini gösteren bir vekil değişkendir (Proxy Variable).

4. Krizlerin Etkisi (2008 Financial Crisis)
Zaman serisi analizinde, 2008 kriz yılında ortalama maaşların düşmek yerine "artmış gibi" göründüğü tespit edilmiştir.

Insight: Bu bir refah artışı değil, Composition Effect (Kompozisyon Etkisi)'dir. Kriz anında düşük maaşlılar işten çıkarılınca, havuzda kalan yüksek maaşlılar ortalamayı yukarı çekmiştir.

5. İş Gücü Personaları (K-Means Clustering)
Makine öğrenmesi algoritması (K-Means) ile iş gücü piyasası 3 ana kümeye ayrılmıştır:

Yeşil Grup: Kariyer başındaki çoğunluk.

Mavi Grup: Kıdemli ama maaşı plato çizmiş orta sınıf.

Kırmızı Grup (Outliers): Eğitim ve yetenekle "Cam Tavanı" kıran elit azınlık.

 Görsellerden Örnekler (Visualizations)
(Buraya projedeki en güvendiğin 2-3 grafiği ekleyebilirsin. Örneğin:)

 Education & Wage ROI
 Demographic Breakdown (Race & Education)
 Sonuç (Conclusion)
Bu proje, veri biliminin sadece kod yazmaktan ibaret olmadığını; verilerin arkasındaki sosyolojik katmanları ve ekonomik tarihçeyi okumanın analistin asıl görevi olduğunu kanıtlamaktadır. 2003-2009 verileri bize tek bir gerçeği fısıldıyor:

"Kriz dönemlerinde ve değişen ekonomik düzende, bireyin en güçlü kalkanı sahip olduğu beşeri sermayedir (Eğitim)."
