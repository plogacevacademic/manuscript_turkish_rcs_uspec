//Changes made by Utku on Oct 14:
//      Changed the debrief text, commented out the old one
//      Added "tekrar" in practice_sep normalMessage since it now takes two spaces with the new practice "Message"
//      Now, "her şey" and "bir şey" is seen as a single item (written with underscore) in filler 15 and 16, as well as in rc 505
//      Changed "otoyla" to "arabayla" in filler 26
//      Change "Şair'in" to "şairin" in filler 55
//      Changed dashes to underscores intro2.html and underlined the words as well
//      Added a practice message right after the practice items.
//          Because It only shows "Deneye başlamak için boşluk tuşuna basınız." 
//          only if you choose the correct answer in the last one. 
//          If you choose the wrong one it says "Odaklanınız .... " and then the experiment just starts.
//
// Remove command prefix
PennController.ResetPrefix(null)

// Turn off debugger
PennController.DebugOff()

var shuffleSequence = seq("intro", 
                          "intro_sep", 
                          sepWith("within_intro_sep", "practice"), 
                          "practice_sep", 
                          sepWith("sep", rshuffle(startsWith("rc_"), startsWith("filler"))), //
                          "send_results",
                         "debrief"); 
var practiceItemTypes = ["practice"];

// default settings
var manualSendResults = true;

var defaults = [
    "Separator", {
        transfer: 1000,
        normalMessage: "",
        errorMessage: ""
    },
    "DashedSentence", {
        hideProgressBar: true,
        mode: "self-paced reading"
    },
    "Question", {
        hideProgressBar: true,
        as: [["q","Evet"], ["p","Hayır"]],
        leftComment: "Q'ya basınız", rightComment: "P'ye basınız",
        presentHorizontally: true,
        hasCorrect: true,
        randomOrder: false
    },
    "Message", {
        hideProgressBar: false
    },
    "Form", {
        hideProgressBar: true,
        continueOnReturn: true,
        saveReactionTime: true,
        continueMessage: "Devam etmek için buraya tıklayınız.",
        obligatoryCheckboxErrorGenerator: function (field) { return "Bu alanı doldurmanız gerekmektedir." },
        obligatoryErrorGenerator: function (field) { return "Bu alanı doldurmanız gerekmektedir."; },
        obligatoryRadioErrorGenerator: function (field) { return "Seçeneklerden birini seçiniz."; }
        
    }
];

function modifyRunningOrder(ro) {
        for (var i = 0; i < ro.length; ++i) {
            if ( (i !== 0) && (i % 40 == 0)) {
                // Passing 'true' as the third argument casues the results from this controller to be omitted from the results file. 
                // (Though in fact, the Message controller does not add any results in any case.)
                ro[i].push(new DynamicElement(
                    "Message",
                    { html: "<p>Kısa bir ara. Bir sonraki cümleye geçmek için boşluk tuşuna basınız.</p>", transfer: "keypress"}, //, transfer: 1000 
                    true
                ));
            }
        }
        return ro;
    }

var items = [
    ["send_results", "__SendResults__", { }],

    ["sep", "Separator", {
        normalMessage: "",
        errorMessage: "",
        ignoreFailure: false}],
    
    ["intro_sep", "Separator", {
        transfer: "keypress",
        normalMessage: "Alıştırma kısmına başlamak için boşluk tuşuna basınız.",
        errorMessage: "Alıştırma kısmına başlamak için boşluk tuşuna basınız." }],


    ["within_intro_sep", "Separator", {
        transfer: "keypress",
        normalMessage: "Harika. İyi gidiyorsunuz. Bir sonraki cümleye geçmek için boşluk tuşuna basınız.",
        errorMessage: "Odaklanınız. Bir sonraki soruya geçmek için boşluk tuşuna basınız."}],
    
    ["practice_sep", "Separator", {
        transfer: "keypress",
        normalMessage: "Deneye başlamak için tekrar boşluk tuşuna basınız.",
        errorMessage: "Odaklanınız. Bir sonraki soruya geçmek için boşluk tuşuna basınız." }],


    ["intro", "Form", {
        html: { include: "intro1.html" },
        obligatoryCheckboxErrorGenerator: function (field) { return "Devam etmeden önce çalismaya katılmayı kabul etmelisiniz."; }
    } ],
    
    ["intro", "Form", {
        html: { include: "intro2.html" },
        validators: {
            age: function (s) { if (s.match(/^\d+$/)) return true; else return "Yaşınızı sayı olarak giriniz."; },
        }
    } ],

    ["intro", "Form", {
        html: { include: "intro3.html" } } ],

    ["intro", "Form", {
        html: { include: "intro4.html" },
        transfer: "keypress"
        //continueMessage: "Alıştırma kısmına başlamak için boşluk tuşuna basınız." 
    } ],

    ["debrief", "Message", {
        html: { include: "debrief.html" },
                transfer: 3000  }],




    //
    // Three practice items for self-paced reading (one with a comprehension question).
    //
    ["practice", "DashedSentence", {s: "Ev arkadaşının bütün ısrarlarına rağmen hiç ders çalışmadı."},
                 "Question",       {q: "Cümleyi anladınız mı?", hasCorrect: 0}], // Y
    ["practice", "DashedSentence", {s: "Kız elindeki fincanı tabağına dikkatle yerleştirdi."},
                 "Question",       {q: "Kız elindeki çatalı mı tabağa yerleştirmiştir?", hasCorrect: 1}], // N
    ["practice", "DashedSentence", {s: "Heykelleri büyük bir dikkatle incelediler ama aralarında bir fark göremediler."},
                 "Question",       {q: "Aralarında bir fark bulundu mu?", hasCorrect: 1}], // N 
    ["practice", "DashedSentence", {s: "O adam tekrar karşılarına çıkınca yine iş istediğini anladılar."},
                 "Question",       {q: "Bir adamdan bahsedildi mi?", hasCorrect: 0}], // Y
    ["practice", "DashedSentence", {s: "İçi rahatlayan bahçıvan huzurla sarayı gezmeye çıkmış."},
                 "Question",       {q: "İçi rahatlayan bahçıvan çalışmak için mi saraya gitmiştir?", hasCorrect: 1}], // N
    ["practice", Message, {
        consentRequired: false, transfer: "keypress",
        html: ["div",
            ["p", "Elinizin ısındığını umuyorum. Hazır olduğunuzu hissettiğinizde 'boşluk' tuşuna basarak ilerleyiniz."],
            ["p", "Katılımınız için çok teşekkürler!"],
        ]
    }],

[['fillers', 1], "DashedSentence", {s: "Birbirlerine aşık olan prenses ve prens, dillere destan bir düğünle evlendiler."} ], 
[['fillers', 2], "DashedSentence", {s: "Bankacı araştırma yaptırdı ama bir türlü işin sırrını çözemedi."} ], 
[['fillers', 3], "DashedSentence", {s: "Kasaplar birbirlerine karşı nefretle konuşmaya ve davranmaya devam ettiler."}, "Question", {q: " Kasaplar sevgiyle mi konuştular?", hasCorrect: 0}],
[['fillers', 4], "DashedSentence", {s: "Tezgahtarlar bütün günün yorgunluğuyla sessizce tabureye oturdu."} ], 
[['fillers', 5], "DashedSentence", {s: "Yeni evlenen gelin kocasıyla birbirlerini delice sevdiklerini sanıyordu."} ], 
[['fillers', 6], "DashedSentence", {s: "Vahşi atları terbiye etmeye çalışan ihtiyarın tek oğlu attan düşmüş ve ayağını kırmış."}, "Question", {q: " İhtiyarın oğlu eşekten mi düşmüş?", hasCorrect: 0}],
[['fillers', 7], "DashedSentence", {s: "Düşmanlar çok daha büyük bir ordu ile köylere tekrar saldırmış."} ], 
[['fillers', 8], "DashedSentence", {s: "Yılların verdiği yorgunlukla bir köşede oturmaktan sıkılan dede pazara doğru yola koyuldu."} ], 
[['fillers', 9], "DashedSentence", {s: "Küçük çocuk baloncuyu takip ederken şaşkınlığını gizleyemiyordu."}, "Question", {q: " Çocuk baloncuyu takip etti mi?", hasCorrect: 1}],
[['fillers', 10], "DashedSentence", {s: "Kaldırım kenarına oturup otobüsün uzaklaşmasını bekledikten sonra, uzun uzun denize baktı."} ], 
[['fillers', 11], "DashedSentence", {s: "Yanında yetiştirdiği öğrencisinin seviyesini kendi geliştirdiği bir testle öğrenmek istedi."} ], 
[['fillers', 12], "DashedSentence", {s: "Kuyumcu kadının elindeki değerli pırlantayı görünce yerinden fırladı."}, "Question", {q: " Kuyumcu pırlantayı gördü mü?", hasCorrect: 1}],
[['fillers', 13], "DashedSentence", {s: "Annesi bebeğini uyurken seyretmek için sessizce odaya girdi."} ], 
[['fillers', 15], "DashedSentence", {s: "Hemşire yanıma yaklaştı ve bağırarak herhangi bir_şeye alerjim olup olmadığını sordu."} ], 
[['fillers', 16], "DashedSentence", {s: "Çırak ustasının yüzündeki ifadeyi gördüğünde her_şeyin yolunda olduğunu anladı."}, "Question", {q: " Çırak kör müydü?", hasCorrect: 0}],
[['fillers', 17], "DashedSentence", {s: "Dükkan sahibi dört haftadır her gün büyük bir heyecanla emlakçıdan gelecek haberi bekliyor."} ], 
[['fillers', 18], "DashedSentence", {s: "Eski dostunu ziyarete gittiği o gün hep çocukluk düşlerinden söz ettiler."} ], 
[['fillers', 19], "DashedSentence", {s: "Sırada beklerken birden dondurmacının vitrinindeki kırmızı oyuncak arabayı gördü."}, "Question", {q: " Araba mavi miydi?", hasCorrect: 0}],
[['fillers', 20], "DashedSentence", {s: "Dördüncü haftanın sonunda artık çekilişi kazanmaktan ümidimi yitirmiştim."} ], 
[['fillers', 21], "DashedSentence", {s: "Yırtık paltolar giymiş iki kişi mahalledeki bütün kapıları çalarak eski gazeteleri istediler."} ], 
[['fillers', 23], "DashedSentence", {s: "Hostes havaalanındaki dükkandan bir kitap alarak bulduğu ilk yere oturdu."}, "Question", {q: " Hostes kitap mı aldı?", hasCorrect: 1}],
[['fillers', 24], "DashedSentence", {s: "Kurabiye yiyip sohbet eden doktorlar anonsu duyunca aceleyle acil servise koşuşturdular."} ], 
[['fillers', 25], "DashedSentence", {s: "Yaşlanmaktan korkan manken tüm hayatı boyunca yasaklar ve kurallarla yaşadı."} ], 
[['fillers', 26], "DashedSentence", {s: "Bu kadar yıllık hayatında ilk defa bir konferansa özel şoförün kullandığı arabayla gidiyordu."}, "Question", {q: " Adamı konferansa şoför mü götürdü?", hasCorrect: 1}],
[['fillers', 27], "DashedSentence", {s: "Uzakdoğu'ya yaptığı o gezide bir Budist tapınağının bilgelik ve gizemle dolu hikayesini dinledi."} ],
[['fillers', 28], "DashedSentence", {s: "Tamirhanede arabanın işinin uzun süreceği söylenen işadamının şoförü hayal kırıklığına uğradı."} ], 
[['fillers', 29], "DashedSentence", {s: "Anneannesi ile birlikte ormanda yürüyüş yapmayı çok seviyordu."}, "Question", {q: " Ormanda babaannesi ile mi yürüyüş yapıyordu?", hasCorrect: 0}],
[['fillers', 30], "DashedSentence", {s: "Kırk beşinci yaş günümü dün gece tek başıma beş şişe bira içerek kutladım."} ], 
[['fillers', 31], "DashedSentence", {s: "Gençlerden bazıları spor kıyafetler içinde yol boyunca koşmaya hazırlanıyordu."} ], 
[['fillers', 32], "DashedSentence", {s: "Soygun için gelen hırsızlar, paniğe kapılıp, bakkalı delik deşik etmiş."}, "Question", {q: " Soygunlar kasabı mı delik deşik etmiş?", hasCorrect: 0}],
[['fillers', 33], "DashedSentence", {s: "Her gün, hayatımızı dolu dolu yaşamayı seçme şansımız ve hakkımız olduğunu ondan öğrendim."} ], 
[['fillers', 34], "DashedSentence", {s: "Bir otelin önünde duran son model Mercedes otomobilden inen adam, hızlı adımlarla bankaya girdi."} ], 
[['fillers', 35], "DashedSentence", {s: "Bütün şövalyelerin aşık olduğu ve evlenmek istediği güzel prenses kral babasıyla birlikte oturuyor."}, "Question", {q: " Prenses babası ile mi yaşıyor?", hasCorrect: 1}],
[['fillers', 36], "DashedSentence", {s: "Zaman kavramından alınan ilhamla tasarlanan oyunun zamana böylesine direnmesi son derece etkileyici."} ], 
[['fillers', 37], "DashedSentence", {s: "Mektubunda işle ilgili hiç bir açıklamadan sadece hemen gelip işe başlamamı söylemiş."} ], 
[['fillers', 39], "DashedSentence", {s: "Babası İspanya'nın en ağır siyasi cezalarının verildiği bir hapishanede mahkumdu küçük kızın."}, "Question", {q: " Kızın babası İspanya'da mı mahkumdu?", hasCorrect: 1}],
[['fillers', 40], "DashedSentence", {s: "Gerçekten de ölüm tüm insanların başına geleceği kaçınılmaz olan tek şeydir."} ], 
[['fillers', 41], "DashedSentence", {s: "İki şapka üreticisi şirket ise yeni aldıkları iki pazarlamacı delikanlıyı Afrika’ya göndermişler."} ], 
[['fillers', 42], "DashedSentence", {s: "Çok yoğun programı olan editör görmek istediği filmin galasına gidemedi."}, "Question", {q: " Editör konsere mi gidemedi?", hasCorrect: 0}], 
[['fillers', 43], "DashedSentence", {s: "Oğlunun büyüdüğünü görmeyen baba emekli olunca tüm vaktini onunla birlikte geçirdi."} ], 
[['fillers', 44], "DashedSentence", {s: "Yeni işe aldığı genç adamın anlattıklarını uzun uzun dinledi."} ], 
[['fillers', 45], "DashedSentence", {s: "Sömestr boyunca çalışmadığı için veremediği bütün dersleri bütünlemede geçti."}, "Question", {q: " İlkokula mı gidiyor?", hasCorrect: 0}],
[['fillers', 46], "DashedSentence", {s: "Konuşmasını önceden hazırlamış ve bir yığın karta kocaman kocaman yazmıştı."} ], 
[['fillers', 47], "DashedSentence", {s: "Kütüphane memuresine giderek gürültü yapanları şikayet etti."} ], 
[['fillers', 48], "DashedSentence", {s: "Misafirleri için özenerek hazırladığı sofra evdeki kedi yüzünden darmadağın oldu."}, "Question", {q: " Evlerinde kedi var mı?", hasCorrect: 1}],
[['fillers', 49], "DashedSentence", {s: "Kardeşine annesinin ona çok sinirlendiğini söyledi."} ], 
[['fillers', 50], "DashedSentence", {s: "Meşhur piyanistin konserlerinden birini dinlemek için gittiğinde kızını da beraberinde götürmüştü."} ], 
[['fillers', 51], "DashedSentence", {s: "Delikanlının ziyaret nedenini açıklamasını dikkatle dinlemiş ama zamanı olmadığını söylemiş ona."}, "Question", {q: " Delikanlıyı dinlemiş mi?", hasCorrect: 1}],
[['fillers', 52], "DashedSentence", {s: "Resmi yarım bırakarak bu iki kişiye model olarak kullanabileceği birilerini aramaya başladı."} ], 
[['fillers', 53], "DashedSentence", {s: "Müşterilerinden gelen her türlü yorum ve fikirlere açık olan yönetim ilginç bir mektupla karşılaştı."} ], 
[['fillers', 54], "DashedSentence", {s: "Uzun bir yürüyüşten sonra oldukça yorulan yaşlı kadın dinlenmek için evine gitti."}, "Question", {q: " Kadın sinemaya mı gitti?", hasCorrect: 0}],
[['fillers', 55], "DashedSentence", {s: "Galata Köprüsü üzerinde dilenen kör bir dilenci bir gün, bir şairin dikkatini çeker."} ],
[['fillers', 56], "DashedSentence", {s: "Akrabalarından biri o küçük erkek çocuğunun belki de evlat edinilmiş olabileceğini söyledi."} ], 
[['fillers', 57], "DashedSentence", {s: "Bir hastane odasındaki iki hasta yerlerinden kalkamadıkları için yattıkları yerden sohbet ediyorlardı."}, "Question", {q: " Hastalar bahçedeler mi?", hasCorrect: 0}],
[['fillers', 58], "DashedSentence", {s: "Şehrin valisi emrindeki yöneticiler ile atının üstünde şatafat içinde girer şehre."} ], 
[['fillers', 59], "DashedSentence", {s: "Bir dost ziyaretinden dönerken yolun ilerisinde kaza olduğunu gördüm."} ], 
[['fillers', 60], "DashedSentence", {s: "Konak, göz alıcı güzellikte güllerin yetiştiği bir bahçenin içinde yer alıyordu."}, "Question", {q: " Konak bahçenin içinde miydi?", hasCorrect: 1}],
[['fillers', 61], "DashedSentence", {s: "Binadan çıkıp otoparktaki arabasına yürürken yanına bir kadın yaklaşmış."} ], 
[['fillers', 62], "DashedSentence", {s: "Yakın dostlarını kahve içmek üzere evine davet etmiş ancak hiç hazırlık yapmamıştı."} ], 
[['fillers', 63], "DashedSentence", {s: "Kendisini affetmesi için yalvaran sevgilisini dinlemeden oradan ayrıldı."}, "Question", {q: " Sevgilisi yalvardı mı?", hasCorrect: 1}],
[['fillers', 64], "DashedSentence", {s: "Upuzun bir kumsal boyunca hayran olduğu kadının ayak izlerini takip ederek yürüdü."} ], 
[['fillers', 66], "DashedSentence", {s: "En acı zamanlarda hayat yolunda yapayalnız yürüdüğünü fark etmek onu fena halde rahatsız etmiş."} ], 
[['fillers', 67], "DashedSentence", {s: "Can sıkıntısının üstesinden gelebilmek için televizyon izlemeye başladı."}, "Question", {q: " Resim mi yaptı?", hasCorrect: 0}],
[['fillers', 68], "DashedSentence", {s: "Adamın yüzünde görülen bencilliği resme geçiriyordu."} ], 
[['fillers', 69], "DashedSentence", {s: "Günlerce aradıktan sonra vaktinden önce yaslanmış olan o genç adamı buldu."}],


[['rc_a', 101], "DashedSentence", {s: "Dün akşam, birbirini döven futbolcuların hayranları stadyumu hemen terk etmek zorunda kaldı."}, "Question", {q: " Hayranlar evlerini mi terketti?", hasCorrect: 0}],
[['rc_b', 102], "DashedSentence", {s: "Öğleden sonra parkta, birbirini gören kuaförün çocukları yüksek sesle ağladı."} ], 
[['rc_c', 103], "DashedSentence", {s: "Oyun bittikten sonra, birbirini çağıran golfçülerin malzemecisi sopaları aldı ve gitti."} ], 
[['rc_d', 104], "DashedSentence", {s: "Geçen onca senenin ardından, kayıp oğlanların kardeşleri gözyaşlarını tutamadı."}, "Question", {q: " Kardeşleri ağladı mı?", hasCorrect: 1}],
[['rc_e', 105], "DashedSentence", {s: "Savaş meydanında, cesur savaşçının komutanları korkusuzca dövüştü."} ],
[['rc_f', 106], "DashedSentence", {s: "Dava mahkemede görüşüldükten sonra, heyecanlı kadınların avukatı hiç konuşmadan kararı bekledi."} ], 
[['rc_a', 107], "DashedSentence", {s: "Saat dördü geçince, birbirini bekleyen adamların amcaları çocukları almaya okula gitti."}, "Question", {q: " Amcalar camiye mi gitti?", hasCorrect: 0}],
[['rc_b', 108], "DashedSentence", {s: "Güneş tam tepedeyken, birbirini tokatlayan milyonerin sevgilileri havuza düştü."} ], 
[['rc_c', 109], "DashedSentence", {s: "Maç çıkışında, birbirine koşan hentbolcuların koçu öfkeyle bağırdı."} ], 
[['rc_d', 110], "DashedSentence", {s: "Çekim bittikten sonra, yakışıklı aktörlerin dublörleri stüdyodan ayrıldı."}, "Question", {q: " Dublörler stüdyodan ayrıldı mı?", hasCorrect: 1}],
[['rc_e', 111], "DashedSentence", {s: "Okul döneminin sonunda, sorunlu gencin terapistleri toplantıda rahat rahat konuştu."} ], 
[['rc_f', 112], "DashedSentence", {s: "Güneş batmaya başladığında, yaşlı tüccarların bahçıvanı ağaçları budamaya gitti."} ], 
[['rc_a', 113], "DashedSentence", {s: "Yemek yenmeden önce, birbiriyle tokalaşan başbakanların personelleri sessizce oturup bekledi."}, "Question", {q: " Personeller çok mu konuştu?", hasCorrect: 0}],
[['rc_b', 201], "DashedSentence", {s: "Mısır tarlasından gelirken, birbirine seslenen çiftçinin kızları sonradan görüşmek üzere ayrıldılar."} ], 
[['rc_c', 202], "DashedSentence", {s: "Eski arkadaş olmalarına rağmen, birbirine dayanamayan artistlerin menajeri çekimden sonra sinirlerine hakim olamadı."} ], 
[['rc_d', 203], "DashedSentence", {s: "Hava karardıktan sonra, ukala milyarderlerin şoförleri arabayı hızla sürmeye başladı."}, "Question", {q: " Hava karanlık mıydı?", hasCorrect: 1}],
[['rc_e', 204], "DashedSentence", {s: "Uzaktan düdük sesi duyulunca, sarhoş evsizin köpekleri karanlığa doğru kaçtı."} ], 
[['rc_f', 205], "DashedSentence", {s: "Perşembe sabahı, ağırbaşlı beyefendilerin postacısı sokaktan geçerken bir kazaya şahit oldular."} ], 
[['rc_a', 206], "DashedSentence", {s: "Bugün akşamüstü, birbirine küfreden boyacıların komşuları çiçeklerini sulamaya başladı."}, "Question", {q: " Komşular uyumaya mı gitti?", hasCorrect: 0}],
[['rc_b', 207], "DashedSentence", {s: "Dövüş sırasında, birbirine vuran boksörün antrenörleri hakeme aldırmadan saygısızca konuştu."} ], 
[['rc_c', 208], "DashedSentence", {s: "İyi geçen ilk gösterinin ardından, birbirine gülümseyen dansçıların eğitmeni dedikodulara aldırmadan salondan çıktı."} ], 
[['rc_d', 209], "DashedSentence", {s: "Seçimden sonra, kararsız politikacıların yandaşları diğer seçmenlerle tartışıp olay çıkardı."}, "Question", {q: " Seçim sonrasında olay çıktı mı?", hasCorrect: 1}],
[['rc_e', 301], "DashedSentence", {s: "Kontratları bitince, tanınmış sporcunun masörleri yeni bir iş aramaya başladı."} ], 
[['rc_f', 302], "DashedSentence", {s: "Sabah içtimasından sonra, genç askerlerin kankası kantinde çay içti."} ], 
[['rc_a', 303], "DashedSentence", {s: "Buluşmanın öncesinde, birbirinden bahseden polislerin muhbirleri kuşku içinde etrafa bakındı."}, "Question", {q: " Muhbirler kör müydü?", hasCorrect: 0}],
[['rc_b', 304], "DashedSentence", {s: "Üç saat sonra, birbirinden sıkılan kızın arkadaşları erkekler hakkında konuşmaya başladı."} ], 
[['rc_c', 305], "DashedSentence", {s: "Genel af çıkacağını duyunca, birbirinden korkan taksicilerin katili polise teslim oldu."} ], 
[['rc_d', 401], "DashedSentence", {s: "Akademik dönem başlarken, rekabetçi profesörlerin asistanları yurt dışındaki bir kongreye gitmek istedi."}, "Question", {q: " Asistanlar kongreye mi gitmek istedi?", hasCorrect: 1}],
[['rc_e', 402], "DashedSentence", {s: "Tenefüs zili çalınca, sinirli öğretmenin öğrencileri oyun oynamak için bahçeye çıktı."} ], 
[['rc_f', 403], "DashedSentence", {s: "Arabaların geçmediği sokakta, yaramaz çocukların kedisi ağaçtan düştü ve oldukça kötü bir şekilde yaralandı."} ], 
[['rc_a', 404], "DashedSentence", {s: "Öğle yemeğinden sonra, birbiriyle vedalaşan doktorların hastaları hastane koşullarını eleştirdi."}, "Question", {q: " Hastalar hastane koşullarını sabah mı eleştirdi?", hasCorrect: 0}],
[['rc_b', 405], "DashedSentence", {s: "Dışarıda kar yağdığı için, birbiriyle konuşan müdürün sekreterleri iliklerine kadar ıslandı."} ], 
[['rc_c', 501], "DashedSentence", {s: "Davet öncesinde, birbirine bağıran aşçıların yamağı mutfakta yemek yapmaya başladı."} ], 
[['rc_d', 502], "DashedSentence", {s: "Sabah erkenden, ağırbaşlı Almanların misafirleri deniz kıyısında güneşlenmeye gitti."}, "Question", {q: " Misafirler deniz kıyısına sabah mı gitti?", hasCorrect: 1}],
[['rc_e', 503], "DashedSentence", {s: "Prensesin düğün gününde, kızgın kralın soytarıları sarayın büyük salonunda alkışlandı."} ], 
[['rc_f', 504], "DashedSentence", {s: "Konser sonrasında, ünlü şarkıcıların vokalisti sarhoş olup sendelemeye başladı."}, "Question", {q: " Vokalist ayık mıydı?", hasCorrect: 0}],
[['rc_a', 505], "DashedSentence", {s: "Ramazan ayında, birbirini kıskanan terzilerin kalfaları iftar yemeğinde her_şeyden yedi."} ], 
[['rc_b', 506], "DashedSentence", {s: "Magazin gazetesindeki habere göre, birbiriyle kavga eden mankenin fotoğrafçıları tatil için Çeşme’ye gitti."}, "Question", {q: " Fotoğrafçılar Çeşme'ye mi gitti?", hasCorrect: 1}],
[['rc_c', 507], "DashedSentence", {s: "Depremden sonra, birbirini anlayan bakanların danışmanı hükumetin hemen harekete geçmesi gerektiğini belirtti."} ], 
[['rc_d', 508], "DashedSentence", {s: "Kitabın kutlama partisinde, sarhoş yazarların muhasebecileri evlilik hakkında konuşmaya başladı."} ], 
[['rc_e', 509], "DashedSentence", {s: "Akşama doğru, titiz mühendisin işçileri lokalde buluşmaya gitti."} ], 
[['rc_f', 510], "DashedSentence", {s: "Sosyal paylaşım sitesinde, yaratıcı heykeltraşların meslektaşı eserlerini yorumlayan eleştirmenlere küfür etti."} ],

[['rc_b', 101], "DashedSentence", {s: "Dün akşam, birbirini döven futbolcunun hayranları stadyumu hemen terk etmek zorunda kaldı."}, "Question", {q: " Hayranlar evlerini mi terketti?", hasCorrect: 0}],
[['rc_c', 102], "DashedSentence", {s: "Öğleden sonra parkta, birbirini gören kuaförlerin çocuğu yüksek sesle ağladı."} ], 
[['rc_d', 103], "DashedSentence", {s: "Oyun bittikten sonra, zengin golfçülerin malzemecileri sopaları aldı ve gitti."} ], 
[['rc_e', 104], "DashedSentence", {s: "Geçen onca senenin ardından, kayıp oğlanın kardeşleri gözyaşlarını tutamadı."}, "Question", {q: " Kardeşleri ağladı mı?", hasCorrect: 1}],
[['rc_f', 105], "DashedSentence", {s: "Savaş meydanında, cesur savaşçıların komutanı korkusuzca dövüştü."} ],
[['rc_a', 106], "DashedSentence", {s: "Dava mahkemede görüşüldükten sonra, birbirini tanıyan kadınların avukatları hiç konuşmadan kararı bekledi."} ], 
[['rc_b', 107], "DashedSentence", {s: "Saat dördü geçince, birbirini bekleyen adamın amcaları çocukları almaya okula gitti."}, "Question", {q: " Amcalar camiye mi gitti?", hasCorrect: 0}],
[['rc_c', 108], "DashedSentence", {s: "Güneş tam tepedeyken, birbirini tokatlayan milyonerlerin sevgilisi havuza düştü."} ], 
[['rc_d', 109], "DashedSentence", {s: "Maç çıkışında, hırslı hentbolcuların koçları öfkeyle bağırdı."} ], 
[['rc_e', 110], "DashedSentence", {s: "Çekim bittikten sonra, yakışıklı aktörün dublörleri stüdyodan ayrıldı."}, "Question", {q: " Dublörler stüdyodan ayrıldı mı?", hasCorrect: 1}],
[['rc_f', 111], "DashedSentence", {s: "Okul döneminin sonunda, sorunlu gençlerin terapisti toplantıda rahat rahat konuştu."} ], 
[['rc_a', 112], "DashedSentence", {s: "Güneş batmaya başladığında, birbirini şikayet eden tüccarların bahçıvanları ağaçları budamaya gitti."} ], 
[['rc_b', 113], "DashedSentence", {s: "Yemek yenmeden önce, birbiriyle tokalaşan başbakanın personelleri sessizce oturup bekledi."}, "Question", {q: " Personeller çok mu konuştu?", hasCorrect: 0}],
[['rc_c', 201], "DashedSentence", {s: "Mısır tarlasından gelirken, birbirine seslenen çiftçilerin kızı sonradan görüşmek üzere ayrıldılar."} ], 
[['rc_d', 202], "DashedSentence", {s: "Eski arkadaş olmalarına rağmen, güzel artistlerin menajerleri çekimden sonra sinirlerine hakim olamadı."} ], 
[['rc_e', 203], "DashedSentence", {s: "Hava karardıktan sonra, ukala milyarderin şoförleri arabayı hızla sürmeye başladı."}, "Question", {q: " Hava karanlık mıydı?", hasCorrect: 1}],
[['rc_f', 204], "DashedSentence", {s: "Uzaktan düdük sesi duyulunca, sarhoş evsizlerin köpeği karanlığa doğru kaçtı."} ], 
[['rc_a', 205], "DashedSentence", {s: "Perşembe sabahı, birbirine selam veren beyefendilerin postacıları sokaktan geçerken bir kazaya şahit oldular."} ], 
[['rc_b', 206], "DashedSentence", {s: "Bugün akşamüstü, birbirine küfreden boyacının komşuları çiçeklerini sulamaya başladı."}, "Question", {q: " Komşular uyumaya mı gitti?", hasCorrect: 0}],
[['rc_c', 207], "DashedSentence", {s: "Dövüş sırasında, birbirine vuran boksörlerin antrenörü hakeme aldırmadan saygısızca konuştu."} ], 
[['rc_d', 208], "DashedSentence", {s: "İyi geçen ilk gösterinin ardından, kibirli dansçıların eğitmenleri dedikodulara aldırmadan salondan çıktı."} ], 
[['rc_e', 209], "DashedSentence", {s: "Seçimden sonra, kararsız politikacının yandaşları diğer seçmenlerle tartışıp olay çıkardı."}, "Question", {q: " Seçim sonrasında olay çıktı mı?", hasCorrect: 1}],
[['rc_f', 301], "DashedSentence", {s: "Kontratları bitince, tanınmış sporcuların masörü yeni bir iş aramaya başladı."} ], 
[['rc_a', 302], "DashedSentence", {s: "Sabah içtimasından sonra, birbirinden şüphelenen askerlerin kankaları kantinde çay içti."} ], 
[['rc_b', 303], "DashedSentence", {s: "Buluşmanın öncesinde, birbirinden bahseden polisin muhbirleri kuşku içinde etrafa bakındı."}, "Question", {q: " Muhbirler kör müydü?", hasCorrect: 0}],
[['rc_c', 304], "DashedSentence", {s: "Üç saat sonra, birbirinden sıkılan kızların arkadaşı erkekler hakkında konuşmaya başladı."} ], 
[['rc_d', 305], "DashedSentence", {s: "Genel af çıkacağını duyunca, Ankaralı taksicilerin katilleri polise teslim oldu."} ], 
[['rc_e', 401], "DashedSentence", {s: "Akademik dönem başlarken, rekabetçi profesörün asistanları yurt dışındaki bir kongreye gitmek istedi."}, "Question", {q: " Asistanlar kongreye mi gitmek istedi?", hasCorrect: 1}],
[['rc_f', 402], "DashedSentence", {s: "Tenefüs zili çalınca, sinirli öğretmenlerin öğrencisi oyun oynamak için bahçeye çıktı."} ], 
[['rc_a', 403], "DashedSentence", {s: "Arabaların geçmediği sokakta, birbiriyle oynayan çocukların kedileri ağaçtan düştü ve oldukça kötü bir şekilde yaralandı."} ], 
[['rc_b', 404], "DashedSentence", {s: "Öğle yemeğinden sonra, birbiriyle vedalaşan doktorun hastaları hastane koşullarını eleştirdi."}, "Question", {q: " Hastalar hastane koşullarını sabah mı eleştirdi?", hasCorrect: 0}],
[['rc_c', 405], "DashedSentence", {s: "Dışarıda kar yağdığı için, birbiriyle konuşan müdürlerin sekreteri iliklerine kadar ıslandı."} ], 
[['rc_d', 501], "DashedSentence", {s: "Davet öncesinde, sakar aşçıların yamakları mutfakta yemek yapmaya başladı."} ], 
[['rc_e', 502], "DashedSentence", {s: "Sabah erkenden, ağırbaşlı Almanın misafirleri deniz kıyısında güneşlenmeye gitti."}, "Question", {q: " Misafirler deniz kıyısına sabah mı gitti?", hasCorrect: 1}],
[['rc_f', 503], "DashedSentence", {s: "Prensesin düğün gününde, kızgın kralların soytarısı sarayın büyük salonunda alkışlandı."} ], 
[['rc_a', 504], "DashedSentence", {s: "Konser sonrasında, birbirine küsen şarkıcıların vokalistleri sarhoş olup sendelemeye başladı."}, "Question", {q: " Vokalistler ayık mıydı?", hasCorrect: 0}],
[['rc_b', 505], "DashedSentence", {s: "Ramazan ayında, birbirini kıskanan terzinin kalfaları iftar yemeğinde her_şeyden yedi."} ], 
[['rc_c', 506], "DashedSentence", {s: "Magazin gazetesindeki habere göre, birbiriyle kavga eden mankenlerin fotoğrafçısı tatil için Çeşme’ye gitti."}, "Question", {q: " Fotoğrafçı Çeşme'ye mi gitti?", hasCorrect: 1}],
[['rc_d', 507], "DashedSentence", {s: "Depremden sonra, gayretli bakanların danışmanları hükumetin hemen harekete geçmesi gerektiğini belirtti."} ], 
[['rc_e', 508], "DashedSentence", {s: "Kitabın kutlama partisinde, sarhoş yazarın muhasebecileri evlilik hakkında konuşmaya başladı."} ], 
[['rc_f', 509], "DashedSentence", {s: "Akşama doğru, titiz mühendislerin işçisi lokalde buluşmaya gitti."} ],
[['rc_a', 510], "DashedSentence", {s: "Sosyal paylaşım sitesinde, birbirini seven heykeltraşların meslektaşları eserlerini yorumlayan eleştirmenlere küfür etti."} ], 

[['rc_c', 101], "DashedSentence", {s: "Dün akşam, birbirini döven futbolcuların hayranı stadyumu hemen terk etmek zorunda kaldı."}, "Question", {q: " Hayran evini mi terketti?", hasCorrect: 0}],
[['rc_d', 102], "DashedSentence", {s: "Öğleden sonra parkta, yetenekli kuaförlerin çocukları yüksek sesle ağladı."} ], 
[['rc_e', 103], "DashedSentence", {s: "Oyun bittikten sonra, zengin golfçünün malzemecileri sopaları aldı ve gitti."} ], 
[['rc_f', 104], "DashedSentence", {s: "Geçen onca senenin ardından, kayıp oğlanların kardeşii gözyaşlarını tutamadı."}, "Question", {q: " Kardeşi ağladı mı?", hasCorrect: 1}],
[['rc_a', 105], "DashedSentence", {s: "Savaş meydanında, birbirini arayan savaşçıların komutanları korkusuzca dövüştü."} ],
[['rc_b', 106], "DashedSentence", {s: "Dava mahkemede görüşüldükten sonra, birbirini tanıyan kadının avukatları hiç konuşmadan kararı bekledi."} ], 
[['rc_c', 107], "DashedSentence", {s: "Saat dördü geçince, birbirini bekleyen adamların amcası çocukları almaya okula gitti."}, "Question", {q: " Amca camiye mi gitti?", hasCorrect: 0}],
[['rc_d', 108], "DashedSentence", {s: "Güneş tam tepedeyken, çapkın milyonerlerin sevgilileri havuza düştü."} ], 
[['rc_e', 109], "DashedSentence", {s: "Maç çıkışında, hırslı hentbolcunun koçları öfkeyle bağırdı."} ], 
[['rc_f', 110], "DashedSentence", {s: "Çekim bittikten sonra, yakışıklı aktörlerin dublörü stüdyodan ayrıldı."}, "Question", {q: " Dublör stüdyodan ayrıldı mı?", hasCorrect: 1}],
[['rc_a', 111], "DashedSentence", {s: "Okul döneminin sonunda, birbirini suçlayan gençlerin terapistleri toplantıda rahat rahat konuştu."} ], 
[['rc_b', 112], "DashedSentence", {s: "Güneş batmaya başladığında, birbirini şikayet eden tüccarın bahçıvanları ağaçları budamaya gitti."} ], 
[['rc_c', 113], "DashedSentence", {s: "Yemek yenmeden önce, birbiriyle tokalaşan başbakanların personeli sessizce oturup bekledi."}, "Question", {q: " Personel çok mu konuştu?", hasCorrect: 0}],
[['rc_d', 201], "DashedSentence", {s: "Mısır tarlasından gelirken, yorgun çiftçilerin kızları sonradan görüşmek üzere ayrıldılar."} ], 
[['rc_e', 202], "DashedSentence", {s: "Eski arkadaş olmalarına rağmen, güzel artistin menajerleri çekimden sonra sinirlerine hakim olamadı."} ], 
[['rc_f', 203], "DashedSentence", {s: "Hava karardıktan sonra, ukala milyarderlerin şoförü arabayı hızla sürmeye başladı."}, "Question", {q: " Hava karanlık mıydı?", hasCorrect: 1}],
[['rc_a', 204], "DashedSentence", {s: "Uzaktan düdük sesi duyulunca, birbirine saldıran evsizlerin köpekleri karanlığa doğru kaçtı."} ], 
[['rc_b', 205], "DashedSentence", {s: "Perşembe sabahı, birbirine selam veren beyefendinin postacıları sokaktan geçerken bir kazaya şahit oldular."} ], 
[['rc_c', 206], "DashedSentence", {s: "Bugün akşamüstü, birbirine küfreden boyacıların komşusu çiçeklerini sulamaya başladı."}, "Question", {q: " Komşu uyumaya mı gitti?", hasCorrect: 0}],
[['rc_d', 207], "DashedSentence", {s: "Dövüş sırasında, ünlü boksörlerin antrenörleri hakeme aldırmadan saygısızca konuştu."} ], 
[['rc_e', 208], "DashedSentence", {s: "İyi geçen ilk gösterinin ardından, kibirli dansçının eğitmenleri dedikodulara aldırmadan salondan çıktı."} ], 
[['rc_f', 209], "DashedSentence", {s: "Seçimden sonra, kararsız politikacıların yandaşı diğer seçmenlerle tartışıp olay çıkardı."}, "Question", {q: " Seçim sonrasında olay çıktı mı?", hasCorrect: 1}],
[['rc_a', 301], "DashedSentence", {s: "Kontratları bitince, birbirinden nefret eden sporcuların masörleri yeni bir iş aramaya başladı."} ], 
[['rc_b', 302], "DashedSentence", {s: "Sabah içtimasından sonra, birbirinden şüphelenen askerin kankaları kantinde çay içti."} ], 
[['rc_c', 303], "DashedSentence", {s: "Buluşmanın öncesinde, birbirinden bahseden polislerin muhbiri kuşku içinde etrafa bakındı."}, "Question", {q: " Muhbir kör müydü?", hasCorrect: 0}],
[['rc_d', 304], "DashedSentence", {s: "Üç saat sonra, şımarık kızların arkadaşları erkekler hakkında konuşmaya başladı."} ], 
[['rc_e', 305], "DashedSentence", {s: "Genel af çıkacağını duyunca, Ankaralı taksicinin katilleri polise teslim oldu."} ], 
[['rc_f', 401], "DashedSentence", {s: "Akademik dönem başlarken, rekabetçi profesörlerin asistanı yurt dışındaki bir kongreye gitmek istedi."}, "Question", {q: " Asistan kongreye mi gitmek istedi?", hasCorrect: 1}],
[['rc_a', 402], "DashedSentence", {s: "Tenefüs zili çalınca, birbiriyle şakalaşan öğretmenlerin öğrencileri oyun oynamak için bahçeye çıktı."} ], 
[['rc_b', 403], "DashedSentence", {s: "Arabaların geçmediği sokakta, birbiriyle oynayan çocuğun kedileri ağaçtan düştü ve oldukça kötü bir şekilde yaralandı."} ], 
[['rc_c', 404], "DashedSentence", {s: "Öğle yemeğinden sonra, birbiriyle vedalaşan doktorların hastası hastane koşullarını eleştirdi."}, "Question", {q: " Hasta hastane koşullarını sabah mı eleştirdi?", hasCorrect: 0}],
[['rc_d', 405], "DashedSentence", {s: "Dışarıda kar yağdığı için, acımasız müdürlerin sekreterleri iliklerine kadar ıslandı."} ], 
[['rc_e', 501], "DashedSentence", {s: "Davet öncesinde, sakar aşçının yamakları mutfakta yemek yapmaya başladı."} ], 
[['rc_f', 502], "DashedSentence", {s: "Sabah erkenden, ağırbaşlı Almanların misafiri deniz kıyısında güneşlenmeye gitti."}, "Question", {q: " Misafir deniz kıyısına sabah mı gitti?", hasCorrect: 1}],
[['rc_a', 503], "DashedSentence", {s: "Prensesin düğün gününde, birbirine gülen kralların soytarıları sarayın büyük salonunda alkışlandı."} ], 
[['rc_b', 504], "DashedSentence", {s: "Konser sonrasında, birbirine küsen şarkıcının vokalistleri sarhoş olup sendelemeye başladı."}, "Question", {q: " Vokalistler ayık mıydı?", hasCorrect: 0}],
[['rc_c', 505], "DashedSentence", {s: "Ramazan ayında, birbirini kıskanan terzilerin kalfası iftar yemeğinde her_şeyden yedi."} ], 
[['rc_d', 506], "DashedSentence", {s: "Magazin gazetesindeki habere göre, sıska mankenlerin fotoğrafçıları tatil için Çeşme’ye gitti."}, "Question", {q: " Fotoğrafçılar Çeşme'ye mi gitti?", hasCorrect: 1}],
[['rc_e', 507], "DashedSentence", {s: "Depremden sonra, gayretli bakanın danışmanları hükumetin hemen harekete geçmesi gerektiğini belirtti."} ], 
[['rc_f', 508], "DashedSentence", {s: "Kitabın kutlama partisinde, sarhoş yazarların muhasebecisi evlilik hakkında konuşmaya başladı."} ],
[['rc_a', 509], "DashedSentence", {s: "Akşama doğru, birbiriyle anlaşan mühendislerin işçileri lokalde buluşmaya gitti."} ], 
[['rc_b', 510], "DashedSentence", {s: "Sosyal paylaşım sitesinde, birbirini seven heykeltraşın meslektaşları eserlerini yorumlayan eleştirmenlere küfür etti."} ], 


[['rc_d', 101], "DashedSentence", {s: "Dün akşam, Fenerbahçeli futbolcuların hayranları stadyumu hemen terk etmek zorunda kaldı."}, "Question", {q: " Hayranlar evlerini mi terketti?", hasCorrect: 0}],
[['rc_e', 102], "DashedSentence", {s: "Öğleden sonra parkta, yetenekli kuaförün çocukları yüksek sesle ağladı."} ], 
[['rc_f', 103], "DashedSentence", {s: "Oyun bittikten sonra, zengin golfçülerin malzemecisi sopaları aldı ve gitti."} ], 
[['rc_a', 104], "DashedSentence", {s: "Geçen onca senenin ardından, birbirini bulan oğlanların kardeşleri gözyaşlarını tutamadı."}, "Question", {q: " Kardeşleri ağladı mı?", hasCorrect: 1}],
[['rc_b', 105], "DashedSentence", {s: "Savaş meydanında, birbirini arayan savaşçının komutanları korkusuzca dövüştü."} ],
[['rc_c', 106], "DashedSentence", {s: "Dava mahkemede görüşüldükten sonra, birbirini tanıyan kadınların avukatı hiç konuşmadan kararı bekledi."} ], 
[['rc_d', 107], "DashedSentence", {s: "Saat dördü geçince, sabırsız adamların amcaları çocukları almaya okula gitti."}, "Question", {q: " Amcalar camiye mi gitti?", hasCorrect: 0}],
[['rc_e', 108], "DashedSentence", {s: "Güneş tam tepedeyken, çapkın milyonerin sevgilileri havuza düştü."} ], 
[['rc_f', 109], "DashedSentence", {s: "Maç çıkışında, hırslı hentbolcuların koçu öfkeyle bağırdı."} ],
[['rc_a', 110], "DashedSentence", {s: "Çekim bittikten sonra, birbirini çekemeyen aktörlerin dublörleri stüdyodan ayrıldı."}, "Question", {q: " Dublörler stüdyodan ayrıldı mı?", hasCorrect: 1}],
[['rc_b', 111], "DashedSentence", {s: "Okul döneminin sonunda, birbirini suçlayan gencin terapistleri toplantıda rahat rahat konuştu."} ], 
[['rc_c', 112], "DashedSentence", {s: "Güneş batmaya başladığında, birbirini şikayet eden tüccarların bahçıvanı ağaçları budamaya gitti."} ], 
[['rc_d', 113], "DashedSentence", {s: "Yemek yenmeden önce, ciddi başbakanların personelleri sessizce oturup bekledi."}, "Question", {q: " Personeller çok mu konuştu?", hasCorrect: 0}],
[['rc_e', 201], "DashedSentence", {s: "Mısır tarlasından gelirken, yorgun çiftçinin kızları sonradan görüşmek üzere ayrıldılar."} ], 
[['rc_f', 202], "DashedSentence", {s: "Eski arkadaş olmalarına rağmen, güzel artistlerin menajeri çekimden sonra sinirlerine hakim olamadı."} ], 
[['rc_a', 203], "DashedSentence", {s: "Hava karardıktan sonra, birbirine kızan milyarderlerin şoförleri arabayı hızla sürmeye başladı."}, "Question", {q: " Hava karanlık mıydı?", hasCorrect: 1}],
[['rc_b', 204], "DashedSentence", {s: "Uzaktan düdük sesi duyulunca, birbirine saldıran evsizin köpekleri karanlığa doğru kaçtı."} ], 
[['rc_c', 205], "DashedSentence", {s: "Perşembe sabahı, birbirine selam veren beyefendilerin postacısı sokaktan geçerken bir kazaya şahit oldular."} ], 
[['rc_d', 206], "DashedSentence", {s: "Bugün akşamüstü, çalışkan boyacıların komşuları çiçeklerini sulamaya başladı."}, "Question", {q: " Komşular uyumaya mı gitti?", hasCorrect: 0}],
[['rc_e', 207], "DashedSentence", {s: "Dövüş sırasında, ünlü boksörün antrenörleri hakeme aldırmadan saygısızca konuştu."} ], 
[['rc_f', 208], "DashedSentence", {s: "İyi geçen ilk gösterinin ardından, kibirli dansçıların eğitmeni dedikodulara aldırmadan salondan çıktı."} ], 
[['rc_a', 209], "DashedSentence", {s: "Seçimden sonra, birbirine sinirlenen politikacıların yandaşları diğer seçmenlerle tartışıp olay çıkardı."}, "Question", {q: " Seçim sonrasında olay çıktı mı?", hasCorrect: 1}],
[['rc_b', 301], "DashedSentence", {s: "Kontratları bitince, birbirinden nefret eden sporcunun masörleri yeni bir iş aramaya başladı."} ], 
[['rc_c', 302], "DashedSentence", {s: "Sabah içtimasından sonra, birbirinden şüphelenen askerlerin kankası kantinde çay içti."} ], 
[['rc_d', 303], "DashedSentence", {s: "Buluşmanın öncesinde, şişman polislerin muhbirleri kuşku içinde etrafa bakındı."}, "Question", {q: " Muhbirler kör müydü?", hasCorrect: 0}],
[['rc_e', 304], "DashedSentence", {s: "Üç saat sonra, şımarık kızın arkadaşları erkekler hakkında konuşmaya başladı."} ], 
[['rc_f', 305], "DashedSentence", {s: "Genel af çıkacağını duyunca, Ankaralı taksicilerin katili polise teslim oldu."} ],
[['rc_a', 401], "DashedSentence", {s: "Akademik dönem başlarken, birbiriyle yarışan profesörlerin asistanları yurt dışındaki bir kongreye gitmek istedi."}, "Question", {q: " Asistanlar kongreye mi gitmek istedi?", hasCorrect: 1}],
[['rc_b', 402], "DashedSentence", {s: "Tenefüs zili çalınca, birbiriyle şakalaşan öğretmenin öğrencileri oyun oynamak için bahçeye çıktı."} ], 
[['rc_c', 403], "DashedSentence", {s: "Arabaların geçmediği sokakta, birbiriyle oynayan çocukların kedisi ağaçtan düştü ve oldukça kötü bir şekilde yaralandı."} ], 
[['rc_d', 404], "DashedSentence", {s: "Öğle yemeğinden sonra, deneyimli doktorların hastaları hastane koşullarını eleştirdi."}, "Question", {q: " Hastalar hastane koşullarını sabah mı eleştirdi?", hasCorrect: 0}],
[['rc_e', 405], "DashedSentence", {s: "Dışarıda kar yağdığı için, acımasız müdürün sekreterleri iliklerine kadar ıslandı."} ], 
[['rc_f', 501], "DashedSentence", {s: "Davet öncesinde, sakar aşçıların yamağı mutfakta yemek yapmaya başladı."} ],
[['rc_a', 502], "DashedSentence", {s: "Sabah erkenden, birbirinden sıkılan Almanların misafirleri deniz kıyısında güneşlenmeye gitti."}, "Question", {q: " Misafirler deniz kıyısına sabah mı gitti?", hasCorrect: 1}],
[['rc_b', 503], "DashedSentence", {s: "Prensesin düğün gününde, birbirine gülen kralın soytarıları sarayın büyük salonunda alkışlandı."} ], 
[['rc_c', 504], "DashedSentence", {s: "Konser sonrasında, birbirine küsen şarkıcıların vokalisti sarhoş olup sendelemeye başladı."}, "Question", {q: " Vokalist ayık mıydı?", hasCorrect: 0}],
[['rc_d', 505], "DashedSentence", {s: "Ramazan ayında, fakir terzilerin kalfaları iftar yemeğinde her_şeyden yedi."} ], 
[['rc_e', 506], "DashedSentence", {s: "Magazin gazetesindeki habere göre, sıska mankenin fotoğrafçıları tatil için Çeşme’ye gitti."}, "Question", {q: " Fotoğrafçılar Çeşme'ye mi gitti?", hasCorrect: 1}],
[['rc_f', 507], "DashedSentence", {s: "Depremden sonra, gayretli bakanların danışmanı hükumetin hemen harekete geçmesi gerektiğini belirtti."} ], 
[['rc_a', 508], "DashedSentence", {s: "Kitabın kutlama partisinde, birbirini soran yazarların muhasebecileri evlilik hakkında konuşmaya başladı."} ], 
[['rc_b', 509], "DashedSentence", {s: "Akşama doğru, birbiriyle anlaşan mühendisin işçileri lokalde buluşmaya gitti."} ], 
[['rc_c', 510], "DashedSentence", {s: "Sosyal paylaşım sitesinde, birbirini seven heykeltraşların meslektaşı eserlerini yorumlayan eleştirmenlere küfür etti."} ], 

[['rc_e', 101], "DashedSentence", {s: "Dün akşam, Fenerbahçeli futbolcunun hayranları stadyumu hemen terk etmek zorunda kaldı."}, "Question", {q: " Hayranlar evlerini mi terketti?", hasCorrect: 0}],
[['rc_f', 102], "DashedSentence", {s: "Öğleden sonra parkta, yetenekli kuaförlerin çocuğu yüksek sesle ağladı."} ], 
[['rc_a', 103], "DashedSentence", {s: "Oyun bittikten sonra, birbirini çağıran golfçülerin malzemecileri sopaları aldı ve gitti."} ], 
[['rc_b', 104], "DashedSentence", {s: "Geçen onca senenin ardından, birbirini bulan oğlanın kardeşleri gözyaşlarını tutamadı."}, "Question", {q: " Kardeşleri ağladı mı?", hasCorrect: 1}],
[['rc_c', 105], "DashedSentence", {s: "Savaş meydanında, birbirini arayan savaşçıların komutanı korkusuzca dövüştü."} ],
[['rc_d', 106], "DashedSentence", {s: "Dava mahkemede görüşüldükten sonra, heyecanlı kadınların avukatları hiç konuşmadan kararı bekledi."} ], 
[['rc_e', 107], "DashedSentence", {s: "Saat dördü geçince, sabırsız adamın amcaları çocukları almaya okula gitti."}, "Question", {q: " Amcalar camiye mi gitti?", hasCorrect: 0}],
[['rc_f', 108], "DashedSentence", {s: "Güneş tam tepedeyken, çapkın milyonerlerin sevgilisi havuza düştü."} ], 
[['rc_a', 109], "DashedSentence", {s: "Maç çıkışında, birbirine koşan hentbolcuların koçları öfkeyle bağırdı."} ], 
[['rc_b', 110], "DashedSentence", {s: "Çekim bittikten sonra, birbirini çekemeyen aktörün dublörleri stüdyodan ayrıldı."}, "Question", {q: " Dublörler stüdyodan ayrıldı mı?", hasCorrect: 1}],
[['rc_c', 111], "DashedSentence", {s: "Okul döneminin sonunda, birbirini suçlayan gençlerin terapisti toplantıda rahat rahat konuştu."} ], 
[['rc_d', 112], "DashedSentence", {s: "Güneş batmaya başladığında, yaşlı tüccarların bahçıvanları ağaçları budamaya gitti."} ], 
[['rc_e', 113], "DashedSentence", {s: "Yemek yenmeden önce, ciddi başbakanın personelleri sessizce oturup bekledi."}, "Question", {q: " Personeller çok mu konuştu?", hasCorrect: 0}],
[['rc_f', 201], "DashedSentence", {s: "Mısır tarlasından gelirken, yorgun çiftçilerin kızı sonradan görüşmek üzere ayrıldılar."} ], 
[['rc_a', 202], "DashedSentence", {s: "Eski arkadaş olmalarına rağmen, birbirine dayanamayan artistlerin menajerleri çekimden sonra sinirlerine hakim olamadı."} ], 
[['rc_b', 203], "DashedSentence", {s: "Hava karardıktan sonra, birbirine kızan milyarderin şoförleri arabayı hızla sürmeye başladı."}, "Question", {q: " Hava karanlık mıydı?", hasCorrect: 1}],
[['rc_c', 204], "DashedSentence", {s: "Uzaktan düdük sesi duyulunca, birbirine saldıran evsizlerin köpeği karanlığa doğru kaçtı."} ], 
[['rc_d', 205], "DashedSentence", {s: "Perşembe sabahı, ağırbaşlı beyefendilerin postacıları sokaktan geçerken bir kazaya şahit oldular."} ], 
[['rc_e', 206], "DashedSentence", {s: "Bugün akşamüstü, çalışkan boyacının komşuları çiçeklerini sulamaya başladı."}, "Question", {q: " Komşular uyumaya mı gitti?", hasCorrect: 0}],
[['rc_f', 207], "DashedSentence", {s: "Dövüş sırasında, ünlü boksörlerin antrenörü hakeme aldırmadan saygısızca konuştu."} ], 
[['rc_a', 208], "DashedSentence", {s: "İyi geçen ilk gösterinin ardından, birbirine gülümseyen dansçıların eğitmenleri dedikodulara aldırmadan salondan çıktı."} ], 
[['rc_b', 209], "DashedSentence", {s: "Seçimden sonra, birbirine sinirlenen politikacının yandaşları diğer seçmenlerle tartışıp olay çıkardı."}, "Question", {q: " Seçim sonrasında olay çıktı mı?", hasCorrect: 1}],
[['rc_c', 301], "DashedSentence", {s: "Kontratları bitince, birbirinden nefret eden sporcuların masörü yeni bir iş aramaya başladı."} ], 
[['rc_d', 302], "DashedSentence", {s: "Sabah içtimasından sonra, genç askerlerin kankaları kantinde çay içti."} ], 
[['rc_e', 303], "DashedSentence", {s: "Buluşmanın öncesinde, şişman polisin muhbirleri kuşku içinde etrafa bakındı."}, "Question", {q: " Muhbirler kör müydü?", hasCorrect: 0}],
[['rc_f', 304], "DashedSentence", {s: "Üç saat sonra, şımarık kızların arkadaşı erkekler hakkında konuşmaya başladı."} ], 
[['rc_a', 305], "DashedSentence", {s: "Genel af çıkacağını duyunca, birbirinden korkan taksicilerin katilleri polise teslim oldu."} ], 
[['rc_b', 401], "DashedSentence", {s: "Akademik dönem başlarken, birbiriyle yarışan profesörün asistanları yurt dışındaki bir kongreye gitmek istedi."}, "Question", {q: " Asistanlar kongreye mi gitmek istedi?", hasCorrect: 1}],
[['rc_c', 402], "DashedSentence", {s: "Tenefüs zili çalınca, birbiriyle şakalaşan öğretmenlerin öğrencisi oyun oynamak için bahçeye çıktı."} ], 
[['rc_d', 403], "DashedSentence", {s: "Arabaların geçmediği sokakta, yaramaz çocukların kedileri ağaçtan düştü ve oldukça kötü bir şekilde yaralandı."} ], 
[['rc_e', 404], "DashedSentence", {s: "Öğle yemeğinden sonra, deneyimli doktorun hastaları hastane koşullarını eleştirdi."}, "Question", {q: " Hastalar hastane koşullarını sabah mı eleştirdi?", hasCorrect: 0}],
[['rc_f', 405], "DashedSentence", {s: "Dışarıda kar yağdığı için, acımasız müdürlerin sekreteri iliklerine kadar ıslandı."} ], 
[['rc_a', 501], "DashedSentence", {s: "Davet öncesinde, birbirine bağıran aşçıların yamakları mutfakta yemek yapmaya başladı."} ], 
[['rc_b', 502], "DashedSentence", {s: "Sabah erkenden, birbirinden sıkılan Almanın misafirleri deniz kıyısında güneşlenmeye gitti."}, "Question", {q: " Misafirler deniz kıyısına sabah mı gitti?", hasCorrect: 1}],
[['rc_c', 503], "DashedSentence", {s: "Prensesin düğün gününde, birbirine gülen kralların soytarısı sarayın büyük salonunda alkışlandı."} ], 
[['rc_d', 504], "DashedSentence", {s: "Konser sonrasında, ünlü şarkıcıların vokalistleri sarhoş olup sendelemeye başladı."}, "Question", {q: " Vokalistler ayık mıydı?", hasCorrect: 0}],
[['rc_e', 505], "DashedSentence", {s: "Ramazan ayında, fakir terzinin kalfaları iftar yemeğinde her_şeyden yedi."} ], 
[['rc_f', 506], "DashedSentence", {s: "Magazin gazetesindeki habere göre, sıska mankenlerin fotoğrafçısı tatil için Çeşme’ye gitti."}, "Question", {q: " Fotoğrafçı Çeşme'ye mi gitti?", hasCorrect: 1}],
[['rc_a', 507], "DashedSentence", {s: "Depremden sonra, birbirini anlayan bakanların danışmanları hükumetin hemen harekete geçmesi gerektiğini belirtti."} ], 
[['rc_b', 508], "DashedSentence", {s: "Kitabın kutlama partisinde, birbirini soran yazarın muhasebecileri evlilik hakkında konuşmaya başladı."} ], 
[['rc_c', 509], "DashedSentence", {s: "Akşama doğru, birbiriyle anlaşan mühendislerin işçisi lokalde buluşmaya gitti."} ], 
[['rc_d', 510], "DashedSentence", {s: "Sosyal paylaşım sitesinde, yaratıcı heykeltraşların meslektaşları eserlerini yorumlayan eleştirmenlere küfür etti."} ], 


[['rc_f', 101], "DashedSentence", {s: "Dün akşam, Fenerbahçeli futbolcuların hayranı stadyumu hemen terk etmek zorunda kaldı."}, "Question", {q: " Hayran evini mi terketti?", hasCorrect: 0}],
[['rc_a', 102], "DashedSentence", {s: "Öğleden sonra parkta, birbirini gören kuaförlerin çocukları yüksek sesle ağladı."} ], 
[['rc_b', 103], "DashedSentence", {s: "Oyun bittikten sonra, birbirini çağıran golfçünün malzemecileri sopaları aldı ve gitti."} ], 
[['rc_c', 104], "DashedSentence", {s: "Geçen onca senenin ardından, birbirini bulan oğlanların kardeşi gözyaşlarını tutamadı."}, "Question", {q: " Kardeşi ağladı mı?", hasCorrect: 1}],
[['rc_d', 105], "DashedSentence", {s: "Savaş meydanında, cesur savaşçıların komutanları korkusuzca dövüştü."} ],
[['rc_e', 106], "DashedSentence", {s: "Dava mahkemede görüşüldükten sonra, heyecanlı kadının avukatları hiç konuşmadan kararı bekledi."} ], 
[['rc_f', 107], "DashedSentence", {s: "Saat dördü geçince, sabırsız adamların amcası çocukları almaya okula gitti."}, "Question", {q: " Amca camiye mi gitti?", hasCorrect: 0}],
[['rc_a', 108], "DashedSentence", {s: "Güneş tam tepedeyken, birbirini tokatlayan milyonerlerin sevgilileri havuza düştü."} ], 
[['rc_b', 109], "DashedSentence", {s: "Maç çıkışında, birbirine koşan hentbolcunun koçları öfkeyle bağırdı."} ], 
[['rc_c', 110], "DashedSentence", {s: "Çekim bittikten sonra, birbirini çekemeyen aktörlerin dublörü stüdyodan ayrıldı."}, "Question", {q: " Dublör stüdyodan ayrıldı mı?", hasCorrect: 1}],
[['rc_d', 111], "DashedSentence", {s: "Okul döneminin sonunda, sorunlu gençlerin terapistleri toplantıda rahat rahat konuştu."} ], 
[['rc_e', 112], "DashedSentence", {s: "Güneş batmaya başladığında, yaşlı tüccarın bahçıvanları ağaçları budamaya gitti."} ], 
[['rc_f', 113], "DashedSentence", {s: "Yemek yenmeden önce, ciddi başbakanların personeli sessizce oturup bekledi."}, "Question", {q: " Personel çok mu konuştu?", hasCorrect: 0}],
[['rc_a', 201], "DashedSentence", {s: "Mısır tarlasından gelirken, birbirine seslenen çiftçilerin kızları sonradan görüşmek üzere ayrıldılar."} ], 
[['rc_b', 202], "DashedSentence", {s: "Eski arkadaş olmalarına rağmen, birbirine dayanamayan artistin menajerleri çekimden sonra sinirlerine hakim olamadı."} ], 
[['rc_c', 203], "DashedSentence", {s: "Hava karardıktan sonra, birbirine kızan milyarderlerin şoförü arabayı hızla sürmeye başladı."}, "Question", {q: " Hava karanlık mıydı?", hasCorrect: 1}],
[['rc_d', 204], "DashedSentence", {s: "Uzaktan düdük sesi duyulunca, sarhoş evsizlerin köpekleri karanlığa doğru kaçtı."} ], 
[['rc_e', 205], "DashedSentence", {s: "Perşembe sabahı, ağırbaşlı beyefendinin postacıları sokaktan geçerken bir kazaya şahit oldular."} ], 
[['rc_f', 206], "DashedSentence", {s: "Bugün akşamüstü, çalışkan boyacıların komşusu çiçeklerini sulamaya başladı."}, "Question", {q: " Komşu uyumaya mı gitti?", hasCorrect: 0}],
[['rc_a', 207], "DashedSentence", {s: "Dövüş sırasında, birbirine vuran boksörlerin antrenörleri hakeme aldırmadan saygısızca konuştu."} ], 
[['rc_b', 208], "DashedSentence", {s: "İyi geçen ilk gösterinin ardından, birbirine gülümseyen dansçının eğitmenleri dedikodulara aldırmadan salondan çıktı."} ], 
[['rc_c', 209], "DashedSentence", {s: "Seçimden sonra, birbirine sinirlenen politikacıların yandaşı diğer seçmenlerle tartışıp olay çıkardı."}, "Question", {q: " Seçim sonrasında olay çıktı mı?", hasCorrect: 1}],
[['rc_d', 301], "DashedSentence", {s: "Kontratları bitince, tanınmış sporcuların masörleri yeni bir iş aramaya başladı."} ], 
[['rc_e', 302], "DashedSentence", {s: "Sabah içtimasından sonra, genç askerin kankaları kantinde çay içti."} ], 
[['rc_f', 303], "DashedSentence", {s: "Buluşmanın öncesinde, şişman polislerin muhbiri kuşku içinde etrafa bakındı."}, "Question", {q: " Muhbir kör müydü?", hasCorrect: 0}],
[['rc_a', 304], "DashedSentence", {s: "Üç saat sonra, birbirinden sıkılan kızların arkadaşları erkekler hakkında konuşmaya başladı."} ], 
[['rc_b', 305], "DashedSentence", {s: "Genel af çıkacağını duyunca, birbirinden korkan taksicinin katilleri polise teslim oldu."} ], 
[['rc_c', 401], "DashedSentence", {s: "Akademik dönem başlarken, birbiriyle yarışan profesörlerin asistanı yurt dışındaki bir kongreye gitmek istedi."}, "Question", {q: " Asistan kongreye mi gitmek istedi?", hasCorrect: 1}],
[['rc_d', 402], "DashedSentence", {s: "Tenefüs zili çalınca, sinirli öğretmenlerin öğrencileri oyun oynamak için bahçeye çıktı."} ], 
[['rc_e', 403], "DashedSentence", {s: "Arabaların geçmediği sokakta, yaramaz çocuğun kedileri ağaçtan düştü ve oldukça kötü bir şekilde yaralandı."} ], 
[['rc_f', 404], "DashedSentence", {s: "Öğle yemeğinden sonra, deneyimli doktorların hastası hastane koşullarını eleştirdi."}, "Question", {q: " Hasta hastane koşullarını sabah mı eleştirdi?", hasCorrect: 0}],
[['rc_a', 405], "DashedSentence", {s: "Dışarıda kar yağdığı için, birbiriyle konuşan müdürlerin sekreterleri iliklerine kadar ıslandı."} ], 
[['rc_b', 501], "DashedSentence", {s: "Davet öncesinde, birbirine bağıran aşçının yamakları mutfakta yemek yapmaya başladı."} ], 
[['rc_c', 502], "DashedSentence", {s: "Sabah erkenden, birbirinden sıkılan Almanların misafiri deniz kıyısında güneşlenmeye gitti."}, "Question", {q: " Misafir deniz kıyısına sabah mı gitti?", hasCorrect: 1}],
[['rc_d', 503], "DashedSentence", {s: "Prensesin düğün gününde, kızgın kralların soytarıları sarayın büyük salonunda alkışlandı."} ], 
[['rc_e', 504], "DashedSentence", {s: "Konser sonrasında, ünlü şarkıcının vokalistleri sarhoş olup sendelemeye başladı."}, "Question", {q: " Vokalistler ayık mıydı?", hasCorrect: 0}],
[['rc_f', 505], "DashedSentence", {s: "Ramazan ayında, fakir terzilerin kalfası iftar yemeğinde her_şeyden yedi."} ], 
[['rc_a', 506], "DashedSentence", {s: "Magazin gazetesindeki habere göre, birbiriyle kavga eden mankenlerin fotoğrafçıları tatil için Çeşme’ye gitti."}, "Question", {q: " Fotoğrafçılar Çeşme'ye mi gitti?", hasCorrect: 1}],
[['rc_b', 507], "DashedSentence", {s: "Depremden sonra, birbirini anlayan bakanın danışmanları hükumetin hemen harekete geçmesi gerektiğini belirtti."} ], 
[['rc_c', 508], "DashedSentence", {s: "Kitabın kutlama partisinde, birbirini soran yazarların muhasebecisi evlilik hakkında konuşmaya başladı."} ], 
[['rc_d', 509], "DashedSentence", {s: "Akşama doğru, titiz mühendislerin işçileri lokalde buluşmaya gitti."} ], 
[['rc_e', 510], "DashedSentence", {s: "Sosyal paylaşım sitesinde, yaratıcı heykeltraşın meslektaşları eserlerini yorumlayan eleştirmenlere küfür etti."} ]


];
