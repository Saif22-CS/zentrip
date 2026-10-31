/// روابط صور ثابتة (Wikimedia Commons) للأماكن السياحية والمدن والسيارات.
///
/// كل رابط اتأكدنا إنه بيرجع HTTP 200، ومع ذلك أي واجهة بتعرض الصور لازم
/// تستخدم `AppNetworkImage` عشان يظهر بديل لو الرابط وقع أو الشبكة ضعيفة.
/// الصور من ويكيميديا كومنز (رخص مفتوحة CC / Public Domain).
abstract class MediaUrls {
  static String _c(String dir, String file) =>
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/$dir/$file/960px-$file';

  static String _en(String dir, String file) =>
      'https://thumb.wikimedia.org/wikipedia/en/thumb/$dir/$file/960px-$file';

  // ── معالم ليبيا ───────────────────────────────────────────────────────
  static final leptisMagna =
      _c('3/33', 'Leptis_Magna_%2829%29_%288288918733%29.jpg');
  static final sabratha = _c('a/a6', 'Theatre_of_Sabratha%2C_Libya.jpg');
  static final cyrene = _c('3/3c', 'Cyrene8.jpg');
  static final ghadames = _c('d/d2', 'Ghadames_Mosque.jpg');
  static final tadrartAcacus = _c('9/91', 'Tadrart_Acacus_1.jpg');
  static final redCastle =
      _c('7/7a', 'Tripoli_-_Eingang_zum_Nationalmuseum.jpg');
  static final marcusAureliusArch =
      _c('4/4e', 'Marcus_Aurelius_Arch_Tripoli_Libya.jpg');
  static final apollonia = _c('d/d4', 'Apollonia_portoriental.jpg');
  static final gurgiMosque =
      _c('c/c3', 'Gurgi_Mosque_Exterior_Tripoli_Libya.JPG');
  static final wawAnNamus = _c('d/dd', 'Waw_an-Namus-Zentrum.jpg');
  static final benghaziCathedral =
      _c('9/95', 'Benghazi_Cathedral_%282025%29.jpg');

  // ── معالم مصر وتونس وتركيا والأردن والإمارات ─────────────────────────────
  static final gizaPyramids =
      _c('9/96', 'Pyramids_of_the_Giza_Necropolis.jpg');
  static final abuSimbel =
      _c('b/b5', 'Ramsis%2C_Aswan_Governorate%2C_Egypt_-_panoramio.jpg');
  static final siwaOasis = _c(
      'a/af', '%D9%8A%D9%88%D9%85_%D8%AC%D8%AF%D9%8A%D8%AF.jpg');
  static final whiteDesert = _c('4/4a',
      'Al_Farafrah%2C_New_Valley_Governorate%2C_Egypt_-_panoramio_%2821%29.jpg');
  static final khanElKhalili = _c('7/74',
      '%D8%AE%D8%A7%D9%86_%D8%A7%D9%84%D8%AE%D9%84%D9%8A%D9%84%D9%8A_1.jpg');
  static final hagiaSophia =
      _c('4/4a', 'Hagia_Sophia_%28228968325%29.jpeg');
  static final blueMosque =
      _c('0/03', 'Istanbul_%2834223582516%29_%28cropped%29.jpg');
  static final elJemAmphitheatre = _c('5/5d',
      'The_Amphitheatre_of_El_Jem%2C_built_around_AD_238_in_Thysdrus_in_Africa_Proconsularis%2C_the_estimated_capacity_is_35%2C000%2C_Tunisia_-_52717762494.jpg');
  static final sidiBouSaid = _c('0/05', 'Sidi_Chebaan.jpg');
  static final petra = _c('e/e8', 'Al_Deir_Petra.JPG');
  static final zayedMosque = _en('7/7d', 'Sheikh_Zayed_Mosque_view.jpg');

  // ── صور المدن (للغلاف في رحلاتي) ─────────────────────────────────────────
  static final cityTripoli = _c('8/8d', 'Tripoli_at_night.jpg');
  static final cityBenghazi = _c('1/15', 'Al_Daawa_alIslamiyah2.JPG');
  static final cityMisrata =
      _c('f/f1', 'Misurata_%28Libia%29_-_fontana.jpg');
  static final cityCairo = _c('7/72',
      'Cairo_Opera_House%2C_Al_Hurriyah_Park_and_the_Nile_river_%2814797782354%29.jpg');
  static final cityTunis = _c('2/22',
      'Minaret_et_patio_de_la_mosqu%C3%A9e_Zitouna_au_centre_de_la_M%C3%A9dina_de_Tunis.jpg');
  static final cityIstanbul =
      _c('c/cb', 'Historical_peninsula_and_modern_skyline_of_Istanbul.jpg');
  static final cityJeddah =
      _c('a/a9', 'Jeddah_Waterfront%2C_Western_Saudi_Arabia_%282026%29.jpg');
  static final cityDubai = _en('c/c7', 'Burj_Khalifa_2021.jpg');

  // ── السيارات ───────────────────────────────────────────────────────────
  static final carYaris =
      _c('3/3e', '2020_Toyota_Yaris_Design_HEV_CVT_1.5_Front.jpg');
  static final carAccent =
      _c('9/9d', '2019_Hyundai_Accent_1.6L%2C_front_10.8.19.jpg');
  static final carPicanto =
      _c('8/8d', '2018_Kia_Picanto_3_Automatic_1.2_Front.jpg');
  static final carRio = _c('c/c4', '2021_Kia_Rio_3_MHEV_facelift_1.0.jpg');
  static final carElantra = _c('a/a4',
      '2023_Hyundai_Elantra_Limited_in_Silver%2C_front_left%2C_04-04-2026.jpg');
  static final carCamry = _c('a/ac',
      '2018_Toyota_Camry_%28ASV70R%29_Ascent_sedan_%282018-08-27%29_01.jpg');
  static final carSportage = _c('5/5d', '2025_Kia_Sportage_S_front_only.jpg');
  static final carRav4 = _c('2/2d',
      '2024_Toyota_RAV4_Prime_XSE_Premium_in_Silver_Sky_with_Midnight_Black_roof%2C_front_left.jpg');
  static final carTucson = _c('6/61',
      'Hyundai_Tucson_1.6_T-GDI_PHEV_Prime_%28IV%29_%E2%80%93_f_05072025.jpg');
  static final carSantaFe = _c('e/e6',
      '2024_Hyundai_Santa_Fe_Luxury_AWD_in_Hampton_Grey%2C_front_left%2C_2024-06-30.jpg');
  static final carPatrol = _c('9/9d',
      '2016_Nissan_Patrol_%28Y62%29_Ti-L_wagon_%282018-09-17%29_01.jpg');
  static final carLandCruiser = _c('6/6d',
      '2021_Toyota_Land_Cruiser_300_3.4_ZX_%28Colombia%29_front_view_04.png');
  static final carBmwX5 = _c('f/f1', '2019_BMW_X5_M50d_Automatic_3.0.jpg');
  static final carEClass = _c('f/fd', 'Mercedes-Benz_W214_1X7A1841.jpg');
  static final carRangeRover = _c('1/17',
      '2022_Land_Rover_Range_Rover_SE_P440e_AWD_Automatic_3.0_Front.jpg');
  static final carTesla3 = _c('a/ab',
      'Tesla_Model_3_%282023%29_Autofr%C3%BChling_Ulm_IMG_9282.jpg');
  static final carTeslaY = _c('e/e7',
      'Tesla_Model_Y_Premium_%28Facelift%29_%E2%80%93_f_05052026.jpg');
  static final carBmwI4 = _c('a/ad', 'BMW_i4_IMG_6695.jpg');
  static final carKiaEv6 = _c('d/d9', '2021_Kia_EV6_GT-Line_S.jpg');
  static final carIoniq5 = _c('8/85',
      'Hyundai_Ioniq_5_AWD_Techniq-Paket_%E2%80%93_f_31122024.jpg');
  static final carHiAce = _c('8/80', '2020_Toyota_HiAce_%28front%29.jpg');
  static final carVito = _c('5/54',
      'Mercedes-Benz_V_250_d_Exclusive_AMG_Line_Lang_%28V_447%29_%E2%80%93_Frontansicht%2C_29._Juni_2016%2C_D%C3%BCsseldorf.jpg');
}
