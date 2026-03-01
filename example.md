/**
 * YAZILIMCI İÇİN KURULUM NOTLARI (README):
 * ----------------------------------------
 * Bu proje React Native CLI veya Expo ile çalıştırılabilir.
 * * 1. Gerekli Bağımlılıklar:
 * npm install react-native-maps lucide-react-native firebase
 * npm install --save-dev @types/react-native
 * * 2. iOS Kurulumu (Mac kullaniyorsaniz):
 * cd ios && pod install
 * * 3. Android Konfigürasyonu:
 * AndroidManifest.xml dosyasina Google Maps API Key eklemeyi unutmayin.
 * <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY"/>
 * * 4. Firebase:
 * - google-services.json (Android) dosyasini /android/app/ içine atin.
 * - GoogleService-Info.plist (iOS) dosyasini Xcode projesine ekleyin.
 */

import React, { useState, useEffect, useRef } from 'react';
import { 
  StyleSheet, View, Text, TouchableOpacity, TextInput, 
  ScrollView, SafeAreaView, StatusBar, Alert, Linking, Platform, Dimensions, Modal
} from 'react-native';

// Harita Modülü
import MapView, { Marker, PROVIDER_GOOGLE } from 'react-native-maps';

// İkon Seti (Lucide)
import { 
  Car, User, List, X, Settings, Phone, 
  Edit, Trash, Download, LogOut, CheckCircle, 
  Navigation, Coffee, MessageCircle, Save, Plus
} from 'lucide-react-native';

// --- SABİTLER & AYARLAR ---
const COLORS = {
  primary: '#fbbf24', // Taksi Sarısı
  secondary: '#000000', // Siyah
  white: '#FFFFFF',
  gray: '#F3F4F6',
  darkGray: '#1F2937',
  red: '#EF4444',
  green: '#10B981', // Müsait Rengi
  blue: '#3B82F6',
  orange: '#F59E0B', // Mola Rengi
  busy: '#DC2626'   // Dolu Rengi
};

// Başlangıç Konumu (Aydın Merkez)
const AYDIN_MERKEZ = {
  latitude: 37.8444,
  longitude: 27.8458,
  latitudeDelta: 0.04,
  longitudeDelta: 0.04,
};

// --- MOCK DATA (Veritabanı Simülasyonu) ---
const INITIAL_DRIVERS = [
  { id: '1', plate: '09 T 0001', lat: 37.8460, lng: 27.8470, status: 'available', taxiStand: 'Merkez', district: 'Efeler', phone: '05550000001', isPremium: true, password: '123', likes: 45 },
  { id: '2', plate: '09 T 0123', lat: 37.8420, lng: 27.8420, status: 'busy', taxiStand: 'Hastane', district: 'Efeler', phone: '05550000002', isPremium: false, password: '123', likes: 12 },
  { id: '3', plate: '09 T 1923', lat: 37.8500, lng: 27.8500, status: 'break', taxiStand: 'Forum', district: 'Efeler', phone: '05550000003', isPremium: false, password: '123', likes: 8 },
];

const INITIAL_REQUESTS = [
  { id: 'r1', plate: '09 T 0001', type: 'phone_change', newPhone: '05329998877', status: 'pending' }
];

const INITIAL_PACKAGES = [
  { id: 'p1', name: 'Standart', price: '500', duration: '1 Ay', isPremium: false },
  { id: 'p2', name: 'Gold Üyelik', price: '1200', duration: '3 Ay', isPremium: true },
];

const INITIAL_SETTINGS = {
  adminPass: '123456',
  whatsappNumber: '905555555555', 
  downloadLink: 'https://aydindabutaksi.com/indir.apk'
};

export default function App() {
  // --- STATE ---
  const [page, setPage] = useState('map'); // 'map', 'login', 'admin', 'driver'
  const [user, setUser] = useState(null);
  
  // Veri State'leri (Firebase yerine geçici state)
  const [drivers, setDrivers] = useState(INITIAL_DRIVERS);
  const [requests, setRequests] = useState(INITIAL_REQUESTS);
  const [packages, setPackages] = useState(INITIAL_PACKAGES);
  const [settings, setSettings] = useState(INITIAL_SETTINGS);
  
  const [selectedDriver, setSelectedDriver] = useState(null);
  const [showListModal, setShowListModal] = useState(false);

  // --- ACTIONS ---

  const openWhatsApp = (type, extraData = "") => {
    let message = "";
    if (type === 'add_taxi') message = "Merhaba, sisteminize taksi eklemek istiyorum.";
    if (type === 'upgrade') message = `Merhaba, ${user?.plate} plakalı aracım için paket yükseltmek istiyorum. Paket: ${extraData}`;
    
    const url = `whatsapp://send?phone=${settings.whatsappNumber}&text=${message}`;
    Linking.openURL(url).catch(() => Alert.alert('Hata', 'WhatsApp yüklü değil.'));
  };

  const handleCall = (phone) => {
    Linking.openURL(`tel:${phone}`);
  };

  const downloadApp = () => {
    Linking.openURL(settings.downloadLink).catch(() => Alert.alert('Hata', 'Link açılamadı.'));
  };

  // --- GİRİŞ & ÇIKIŞ ---
  const handleLogin = (plateText, passText) => {
    const plate = plateText.toUpperCase().trim();
    const pass = passText.trim();

    if (plate === 'ADMIN' && pass === settings.adminPass) {
      setUser({ id: 'admin', role: 'admin' });
      setPage('admin');
      return;
    }

    const foundDriver = drivers.find(d => d.plate === plate && d.password === pass);
    if (foundDriver) {
      setUser({ ...foundDriver, role: 'driver' });
      setPage('driver');
    } else {
      Alert.alert("Hata", "Plaka veya şifre yanlış.");
    }
  };

  const handleLogout = () => {
    setUser(null);
    setPage('map');
    setSelectedDriver(null);
  };

  // --- EKRAN BİLEŞENLERİ ---

  // 1. HARİTA EKRANI (MÜŞTERİ)
  const renderMapScreen = () => {
    const visibleDrivers = drivers.filter(d => d.status !== 'break' && d.status !== 'suspended');

    return (
      <View style={styles.container}>
        <StatusBar barStyle="dark-content" />
        <MapView
          style={styles.map}
          initialRegion={AYDIN_MERKEZ}
          provider={PROVIDER_GOOGLE}
        >
          {visibleDrivers.map(d => (
            <Marker
              key={d.id}
              coordinate={{ latitude: d.lat, longitude: d.lng }}
              onPress={() => setSelectedDriver(d)}
            >
              <View style={[
                styles.markerBadge, 
                { 
                  backgroundColor: d.status === 'busy' ? COLORS.busy : COLORS.green, 
                  borderColor: d.isPremium ? '#FFD700' : 'white' 
                }
              ]}>
                <Text style={{fontSize: 20}}>🚖</Text>
              </View>
              {d.status === 'busy' && (
                 <View style={styles.busyLabel}><Text style={styles.busyLabelText}>DOLU</Text></View>
              )}
            </Marker>
          ))}
        </MapView>

        {/* Üst Bar */}
        <SafeAreaView style={styles.topBarContainer} pointerEvents="box-none">
          <View style={styles.topBar}>
            <View style={styles.brandBadge}>
              <View style={styles.brandIconBg}><Car color="black" size={20} /></View>
              <View>
                <Text style={styles.brandTitle}>AydınDaBu</Text>
                <Text style={styles.brandSubtitle}>TAKSİ</Text>
              </View>
            </View>
            <View style={{flexDirection: 'row', gap: 8}}>
              <TouchableOpacity style={styles.topBtn} onPress={() => setPage('login')}>
                <User color="black" size={16} />
                <Text style={styles.topBtnText}>GİRİŞ</Text>
              </TouchableOpacity>
              <TouchableOpacity style={[styles.topBtn, { backgroundColor: COLORS.primary }]} onPress={() => setShowListModal(true)}>
                <List color="black" size={16} />
                <Text style={styles.topBtnText}>LİSTE</Text>
              </TouchableOpacity>
            </View>
          </View>
        </SafeAreaView>

        {/* İndirme Barı */}
        <View style={styles.bottomDownloadBar}>
            <View>
                <Text style={{fontWeight:'bold', fontSize:14}}>Taksici misin?</Text>
                <Text style={{fontSize:12, color:'#666'}}>Hemen indir, kazan!</Text>
            </View>
            <TouchableOpacity onPress={downloadApp} style={styles.downloadButton}>
                <Download color="white" size={16} />
                <Text style={{color:'white', fontWeight:'bold', fontSize:12, marginLeft:5}}>İNDİR</Text>
            </TouchableOpacity>
        </View>

        {/* Sürücü Kartı (Popup) */}
        {selectedDriver && (
          <View style={styles.driverCardOverlay}>
            <View style={styles.driverCard}>
              <View style={styles.cardHeader}>
                <View style={[styles.cardIconBox, {backgroundColor: selectedDriver.status === 'busy' ? COLORS.busy : COLORS.primary}]}>
                    <Text style={{fontSize:24}}>🚖</Text>
                </View>
                <View style={{ flex: 1 }}>
                  <Text style={styles.cardPlate}>{selectedDriver.plate}</Text>
                  <Text style={styles.cardStand}>{selectedDriver.taxiStand} ({selectedDriver.district})</Text>
                  <View style={styles.cardTags}>
                    {selectedDriver.isPremium && <Text style={styles.tagPremium}>⭐ PRO</Text>}
                    <Text style={styles.tagLikes}>❤️ {selectedDriver.likes}</Text>
                    {selectedDriver.status === 'busy' && <Text style={styles.tagBusy}>DOLU</Text>}
                  </View>
                </View>
                <TouchableOpacity onPress={() => setSelectedDriver(null)}>
                  <X color="#999" size={24} />
                </TouchableOpacity>
              </View>
              
              {selectedDriver.status === 'available' ? (
                <TouchableOpacity style={styles.callButton} onPress={() => handleCall(selectedDriver.phone)}>
                  <Phone color="white" size={20} />
                  <Text style={styles.callButtonText}>HEMEN ARA</Text>
                </TouchableOpacity>
              ) : (
                <View style={[styles.callButton, {backgroundColor: '#ccc'}]}>
                  <Text style={styles.callButtonText}>ŞU AN DOLU</Text>
                </View>
              )}
            </View>
          </View>
        )}

        {/* Liste Modalı */}
        <Modal visible={showListModal} animationType="slide" transparent={true}>
          <View style={styles.modalOverlay}>
            <View style={styles.modalContent}>
              <View style={styles.modalHeader}>
                <Text style={styles.modalTitle}>Müsait Taksiler</Text>
                <TouchableOpacity onPress={() => setShowListModal(false)}>
                  <X color="black" size={24} />
                </TouchableOpacity>
              </View>
              <ScrollView contentContainerStyle={{ padding: 16 }}>
                {visibleDrivers.filter(d => d.status === 'available').length === 0 ? (
                  <Text style={{ textAlign: 'center', color: '#999', marginTop: 20 }}>Şu an müsait taksi yok.</Text>
                ) : (
                  visibleDrivers.filter(d => d.status === 'available').map(d => (
                    <TouchableOpacity 
                      key={d.id} 
                      style={styles.listItem} 
                      onPress={() => { setSelectedDriver(d); setShowListModal(false); }}
                    >
                      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
                        <View style={styles.listIconBox}><Text>🚖</Text></View>
                        <View>
                          <Text style={styles.listPlate}>{d.plate}</Text>
                          <Text style={styles.listStand}>{d.taxiStand}</Text>
                        </View>
                      </View>
                      <Text style={{ color: COLORS.red, fontWeight: 'bold' }}>❤️ {d.likes}</Text>
                    </TouchableOpacity>
                  ))
                )}
              </ScrollView>
            </View>
          </View>
        </Modal>
      </View>
    );
  };

  // 2. GİRİŞ EKRANI
  const renderLoginScreen = () => {
    const [plateInput, setPlateInput] = useState('');
    const [passInput, setPassInput] = useState('');

    return (
      <SafeAreaView style={styles.loginContainer}>
        <TouchableOpacity style={styles.backButton} onPress={() => setPage('map')}>
          <Text style={{ color: '#666', fontWeight: 'bold' }}>← Geri Dön</Text>
        </TouchableOpacity>
        
        <View style={styles.loginCard}>
          <View style={styles.loginHeader}>
            <View style={{width: 60, height: 60, backgroundColor: COLORS.primary, borderRadius: 20, alignItems: 'center', justifyContent: 'center', marginBottom: 15}}>
              <User color="black" size={30} />
            </View>
            <Text style={styles.loginTitle}>GİRİŞ YAP</Text>
            <Text style={styles.loginSubtitle}>Sürücü veya Yönetici Paneli</Text>
          </View>
          
          <View style={{ gap: 16 }}>
            <TextInput 
              style={styles.input} 
              placeholder="PLAKA (veya ADMIN)" 
              placeholderTextColor="#999"
              autoCapitalize="characters"
              value={plateInput}
              onChangeText={setPlateInput}
            />
            <TextInput 
              style={styles.input} 
              placeholder="ŞİFRE" 
              placeholderTextColor="#999"
              secureTextEntry
              value={passInput}
              onChangeText={setPassInput}
            />
            <TouchableOpacity 
              style={styles.loginButton}
              onPress={() => handleLogin(plateInput, passInput)}
            >
              <Text style={styles.loginButtonText}>GİRİŞ YAP</Text>
            </TouchableOpacity>

            <TouchableOpacity 
                style={styles.whatsappButton} 
                onPress={() => openWhatsApp('add_taxi')}
            >
                <MessageCircle color={COLORS.green} size={20} />
                <Text style={{color: COLORS.green, fontWeight: 'bold', marginLeft: 8}}>TAKSİNİ EKLE / BAŞVUR</Text>
            </TouchableOpacity>
          </View>
        </View>
      </SafeAreaView>
    );
  };

  // 3. ADMİN PANELİ
  const renderAdminPanel = () => {
    const [tab, setTab] = useState('taxis'); 
    const [form, setForm] = useState({ id: null, plate: '', pass: '', stand: '', phone: '', premium: false });
    
    // Admin Fonksiyonları
    const saveDriver = () => {
      if(!form.plate || !form.pass) return;
      if(form.id) {
        setDrivers(drivers.map(d => d.id === form.id ? { ...d, plate: form.plate, password: form.pass, taxiStand: form.stand, phone: form.phone, isPremium: form.premium } : d));
        Alert.alert("Bilgi", "Sürücü güncellendi.");
      } else {
        const newDriver = {
          id: Date.now().toString(),
          plate: form.plate.toUpperCase(),
          password: form.pass,
          taxiStand: form.stand || 'Merkez',
          district: 'Efeler',
          phone: form.phone || '0555...',
          status: 'available',
          lat: AYDIN_MERKEZ.latitude, lng: AYDIN_MERKEZ.longitude,
          isPremium: form.premium,
          likes: 0
        };
        setDrivers([...drivers, newDriver]);
        Alert.alert("Bilgi", "Sürücü eklendi.");
      }
      setForm({ id: null, plate: '', pass: '', stand: '', phone: '', premium: false });
    };

    const toggleStatus = (id) => {
      setDrivers(drivers.map(d => d.id === id ? { ...d, status: d.status === 'suspended' ? 'available' : 'suspended' } : d));
    };

    const deleteDriver = (id) => {
      Alert.alert("Sil", "Emin misiniz?", [
        { text: "İptal", style: "cancel" },
        { text: "Sil", onPress: () => setDrivers(drivers.filter(d => d.id !== id)), style: 'destructive' }
      ]);
    };

    const approveRequest = (req) => {
      setDrivers(drivers.map(d => d.plate === req.plate ? { ...d, phone: req.newPhone } : d));
      setRequests(requests.filter(r => r.id !== req.id));
      Alert.alert("Bilgi", "İstek onaylandı.");
    };

    return (
      <View style={styles.adminContainer}>
        <SafeAreaView style={{ backgroundColor: COLORS.secondary }}>
          <View style={styles.adminHeader}>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
              <Settings color={COLORS.primary} size={24} />
              <Text style={styles.adminTitle}>ADMİN PANELİ</Text>
            </View>
            <TouchableOpacity onPress={handleLogout} style={styles.logoutButtonSmall}>
              <LogOut color="white" size={16} />
            </TouchableOpacity>
          </View>
        </SafeAreaView>

        {/* Tabs */}
        <View style={styles.tabs}>
          {['taxis', 'requests', 'packages', 'settings'].map(t => (
            <TouchableOpacity 
              key={t} 
              style={[styles.tabItem, tab === t && styles.tabActive]}
              onPress={() => setTab(t)}
            >
              <Text style={[styles.tabText, tab === t && styles.tabTextActive]}>
                {t === 'taxis' ? 'TAKSİ' : t === 'requests' ? `İSTEK(${requests.length})` : t === 'packages' ? 'PAKET' : 'AYAR'}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        <ScrollView style={styles.adminContent}>
            {/* TAKSİLER */}
            {tab === 'taxis' && (
                <View>
                    <View style={styles.adminCard}>
                        <Text style={styles.cardSectionTitle}>{form.id ? 'Düzenle' : 'Hızlı Ekle'}</Text>
                        <View style={{gap:8}}>
                            <View style={{flexDirection:'row', gap:8}}>
                                <TextInput style={[styles.miniInput, {flex:1}]} placeholder="PLAKA" value={form.plate} onChangeText={t=>setForm({...form, plate:t})} />
                                <TextInput style={[styles.miniInput, {flex:1}]} placeholder="ŞİFRE" value={form.pass} onChangeText={t=>setForm({...form, pass:t})} />
                            </View>
                            <View style={{flexDirection:'row', gap:8}}>
                                <TextInput style={[styles.miniInput, {flex:1}]} placeholder="TEL" value={form.phone} onChangeText={t=>setForm({...form, phone:t})} />
                                <TextInput style={[styles.miniInput, {flex:1}]} placeholder="DURAK" value={form.stand} onChangeText={t=>setForm({...form, stand:t})} />
                            </View>
                            <TouchableOpacity onPress={()=>setForm({...form, premium: !form.premium})} style={{flexDirection:'row', alignItems:'center', gap:8, padding:5}}>
                                <View style={{width:20, height:20, borderWidth:1, backgroundColor: form.premium ? COLORS.primary : 'white', borderRadius: 4}} />
                                <Text>Premium Üye</Text>
                            </TouchableOpacity>
                            <TouchableOpacity style={styles.addButton} onPress={saveDriver}>
                                <Text style={{color:'white', fontWeight:'bold'}}>{form.id ? 'GÜNCELLE' : 'KAYDET'}</Text>
                            </TouchableOpacity>
                        </View>
                    </View>

                    {drivers.map(d => (
                        <View key={d.id} style={[styles.driverRow, d.status === 'suspended' && {backgroundColor:'#fee2e2'}]}>
                            <View>
                                <Text style={styles.rowTitle}>{d.plate} {d.isPremium && '⭐'}</Text>
                                <Text style={styles.rowSubtitle}>{d.taxiStand} - {d.status}</Text>
                            </View>
                            <View style={{flexDirection:'row', gap:8}}>
                                <TouchableOpacity style={[styles.iconBtn, {backgroundColor: '#dbeafe'}]} onPress={()=>setForm({id:d.id, plate:d.plate, pass:d.password, stand:d.taxiStand, phone:d.phone, premium:d.isPremium})}>
                                    <Edit color={COLORS.blue} size={18} />
                                </TouchableOpacity>
                                <TouchableOpacity style={[styles.iconBtn, {backgroundColor: d.status === 'suspended' ? '#dcfce7' : '#fee2e2'}]} onPress={()=>toggleStatus(d.id)}>
                                    {d.status === 'suspended' ? <CheckCircle color={COLORS.green} size={18} /> : <X color={COLORS.red} size={18} />}
                                </TouchableOpacity>
                                <TouchableOpacity style={[styles.iconBtn, {backgroundColor: '#f3f4f6'}]} onPress={()=>deleteDriver(d.id)}>
                                    <Trash color={COLORS.secondary} size={18} />
                                </TouchableOpacity>
                            </View>
                        </View>
                    ))}
                </View>
            )}
            
            {/* İSTEKLER */}
            {tab === 'requests' && requests.map(r => (
                <View key={r.id} style={styles.requestCard}>
                    <Text style={{fontWeight:'bold'}}>{r.plate} - Telefon Değişimi</Text>
                    <Text style={{color:'#666'}}>Yeni: {r.newPhone}</Text>
                    <View style={{flexDirection:'row', gap:8, marginTop:8}}>
                        <TouchableOpacity style={[styles.reqBtn, {backgroundColor: COLORS.green}]} onPress={()=>approveRequest(r)}>
                            <Text style={{color:'white', fontWeight:'bold'}}>ONAYLA</Text>
                        </TouchableOpacity>
                        <TouchableOpacity style={[styles.reqBtn, {backgroundColor: COLORS.red}]} onPress={()=>setRequests(requests.filter(req=>req.id!==r.id))}>
                            <Text style={{color:'white', fontWeight:'bold'}}>REDDET</Text>
                        </TouchableOpacity>
                    </View>
                </View>
            ))}
        </ScrollView>
      </View>
    );
  };

  // 4. SÜRÜCÜ PANELİ
  const renderDriverPanel = () => {
    const [subPage, setSubPage] = useState('main'); 
    const currentDriver = drivers.find(d => d.id === user.id) || user;
    const [status, setStatus] = useState(currentDriver.status);
    
    // Profil Edit State
    const [editPhone, setEditPhone] = useState(currentDriver.phone);
    const [editPass, setEditPass] = useState(currentDriver.password);

    const updateStatus = (newStatus) => {
        setStatus(newStatus);
        setDrivers(drivers.map(d => d.id === user.id ? { ...d, status: newStatus } : d));
    };

    const updateProfile = () => {
        if (editPass !== currentDriver.password) {
            setDrivers(drivers.map(d => d.id === user.id ? { ...d, password: editPass } : d));
            Alert.alert("Başarılı", "Şifreniz güncellendi.");
        }
        if (editPhone !== currentDriver.phone) {
            setRequests([...requests, { id: Date.now().toString(), plate: user.plate, type: 'phone_change', newPhone: editPhone, status: 'pending' }]);
            Alert.alert("Bilgi", "Numara değişikliği isteği admine gönderildi.");
        }
    };

    return (
      <View style={styles.driverContainer}>
        <View style={styles.driverHeader}>
          <SafeAreaView>
          <View style={{flexDirection:'row', justifyContent:'space-between', alignItems:'center', paddingHorizontal:20, paddingTop:10}}>
            <View>
                <Text style={styles.driverPlate}>{user.plate}</Text>
                <Text style={styles.driverStatusText}>
                {status === 'available' ? '🟢 MÜSAİT' : status === 'busy' ? '🔴 DOLU' : '☕ MOLADA'}
                </Text>
            </View>
            <View style={{flexDirection:'row', gap:10}}>
                <TouchableOpacity onPress={downloadApp} style={styles.headerIconBtn}><Download color="black" size={20}/></TouchableOpacity>
                <TouchableOpacity onPress={handleLogout} style={styles.headerIconBtn}><LogOut color="black" size={20}/></TouchableOpacity>
            </View>
          </View>
          </SafeAreaView>
        </View>

        {/* Driver Tabs */}
        <View style={styles.tabs}>
           <TouchableOpacity onPress={()=>setSubPage('main')} style={[styles.tabItem, subPage === 'main' && styles.tabActive]}><Text style={styles.tabText}>DURUM</Text></TouchableOpacity>
           <TouchableOpacity onPress={()=>setSubPage('profile')} style={[styles.tabItem, subPage === 'profile' && styles.tabActive]}><Text style={styles.tabText}>PROFİL</Text></TouchableOpacity>
           <TouchableOpacity onPress={()=>setSubPage('packages')} style={[styles.tabItem, subPage === 'packages' && styles.tabActive]}><Text style={styles.tabText}>PAKET</Text></TouchableOpacity>
        </View>

        <ScrollView style={styles.driverBody}>
          {subPage === 'main' && (
            <View style={styles.statusGrid}>
                <TouchableOpacity onPress={()=>updateStatus('available')} style={[styles.statusBtn, status === 'available' ? {backgroundColor: COLORS.green} : {backgroundColor:'white'}]}>
                    <CheckCircle size={32} color={status === 'available' ? 'white' : 'black'} />
                    <Text style={{fontWeight:'bold', color: status === 'available' ? 'white' : 'black'}}>MÜSAİT</Text>
                </TouchableOpacity>

                <TouchableOpacity onPress={()=>updateStatus('busy')} style={[styles.statusBtn, status === 'busy' ? {backgroundColor: COLORS.busy} : {backgroundColor:'white'}]}>
                    <Navigation size={32} color={status === 'busy' ? 'white' : 'black'} />
                    <Text style={{fontWeight:'bold', color: status === 'busy' ? 'white' : 'black'}}>DOLU</Text>
                </TouchableOpacity>

                <TouchableOpacity onPress={()=>updateStatus('break')} style={[styles.statusBtn, {width:'100%', marginTop:10}, status === 'break' ? {backgroundColor: COLORS.orange} : {backgroundColor:'white'}]}>
                    <Coffee size={32} color={status === 'break' ? 'white' : 'gray'} />
                    <Text style={{fontWeight:'bold', color: status === 'break' ? 'white' : 'gray'}}>MOLA VER (GİZLEN)</Text>
                </TouchableOpacity>

                <View style={styles.statRow}>
                    <View style={styles.statBox}><Text style={styles.statVal}>4.8</Text><Text style={styles.statLabel}>PUAN</Text></View>
                    <View style={styles.statBox}><Text style={styles.statVal}>{user.likes}</Text><Text style={styles.statLabel}>BEĞENİ</Text></View>
                </View>
            </View>
          )}

          {subPage === 'profile' && (
              <View style={styles.adminCard}>
                  <Text style={styles.cardSectionTitle}>Bilgilerimi Düzenle</Text>
                  <Text style={styles.inputLabel}>Telefon No</Text>
                  <TextInput style={styles.input} value={editPhone} onChangeText={setEditPhone} keyboardType="phone-pad" />
                  <Text style={styles.inputLabel}>Şifre</Text>
                  <TextInput style={styles.input} value={editPass} onChangeText={setEditPass} />
                  <TouchableOpacity style={styles.addButton} onPress={updateProfile}>
                      <Save size={16} color="white" />
                      <Text style={{color:'white', fontWeight:'bold', marginLeft:5}}>KAYDET</Text>
                  </TouchableOpacity>
              </View>
          )}

          {subPage === 'packages' && (
              <View style={{gap:10}}>
                  {packages.map(p => (
                      <View key={p.id} style={[styles.adminCard, p.isPremium && {borderColor:COLORS.primary, borderWidth:2}]}>
                          <View style={{flexDirection:'row', justifyContent:'space-between'}}>
                              <Text style={{fontWeight:'bold', fontSize:16}}>{p.name} {p.isPremium && '⭐'}</Text>
                              <Text style={{color:COLORS.primary, fontWeight:'bold'}}>{p.price} TL</Text>
                          </View>
                          <Text style={{color:'#666', marginBottom:10}}>{p.duration}</Text>
                          <TouchableOpacity style={styles.whatsappButton} onPress={()=>openWhatsApp('upgrade', p.name)}>
                              <MessageCircle color={COLORS.green} size={18} />
                              <Text style={{color:COLORS.green, fontWeight:'bold', marginLeft:5}}>SATIN AL</Text>
                          </TouchableOpacity>
                      </View>
                  ))}
              </View>
          )}
        </ScrollView>
      </View>
    );
  };

  // Navigation Logic
  if (page === 'map') return renderMapScreen();
  if (page === 'login') return renderLoginScreen();
  if (page === 'admin') return renderAdminPanel();
  if (page === 'driver') return renderDriverPanel();
  return null;
}

// --- STYLES ---
const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  map: { ...StyleSheet.absoluteFillObject },
  
  // Marker
  markerBadge: {
    width: 44, height: 44, borderRadius: 22,
    alignItems: 'center', justifyContent: 'center',
    borderWidth: 3, 
    shadowColor: "#000", shadowOffset: {width:0, height:2}, shadowOpacity:0.3, shadowRadius:4
  },
  busyLabel: { position:'absolute', bottom:-15, left:-5, backgroundColor:'white', paddingHorizontal:4, borderRadius:4, borderWidth:1, borderColor:COLORS.busy },
  busyLabelText: { fontSize:10, fontWeight:'bold', color:COLORS.busy },

  // Top Bar
  topBarContainer: { position: 'absolute', top: 0, left: 0, right: 0 },
  topBar: { flexDirection: 'row', justifyContent: 'space-between', padding: 16, alignItems: 'flex-start' },
  brandBadge: {
    flexDirection: 'row', alignItems: 'center', backgroundColor: 'rgba(255,255,255,0.95)',
    padding: 8, paddingRight: 16, borderRadius: 16, gap: 8,
    shadowColor: "#000", shadowOffset: {width:0, height:2}, shadowOpacity:0.1, shadowRadius:4
  },
  brandIconBg: { backgroundColor: COLORS.primary, padding: 6, borderRadius: 8 },
  brandTitle: { fontWeight: 'bold', fontSize: 14, color: COLORS.secondary },
  brandSubtitle: { fontSize: 10, fontWeight: 'bold', color: '#666' },
  topBtn: { 
    flexDirection: 'row', alignItems: 'center', backgroundColor: 'white', padding: 10, 
    borderRadius: 12, gap: 6, shadowColor: "#000", shadowOffset: {width:0, height:2}, shadowOpacity:0.1, shadowRadius:3 
  },
  topBtnText: { fontWeight: 'bold', fontSize: 12 },

  // Download Bar
  bottomDownloadBar: {
      position: 'absolute', bottom: 30, left: 16, right: 16,
      backgroundColor: 'white', padding: 15, borderRadius: 20,
      flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
      shadowColor: "#000", shadowOffset: {width:0, height:5}, shadowOpacity:0.2, shadowRadius:10
  },
  downloadButton: {
      backgroundColor: 'black', flexDirection: 'row', alignItems: 'center', paddingVertical: 8, paddingHorizontal: 15, borderRadius: 10
  },

  // Driver Card
  driverCardOverlay: { position: 'absolute', bottom: 100, left: 16, right: 16 },
  driverCard: { 
    backgroundColor: 'white', borderRadius: 24, padding: 20,
    shadowColor: "#000", shadowOffset: {width:0, height:10}, shadowOpacity:0.2, shadowRadius:20, elevation: 10
  },
  cardHeader: { flexDirection: 'row', gap: 16, marginBottom: 16 },
  cardIconBox: { width: 60, height: 60, borderRadius: 16, alignItems: 'center', justifyContent: 'center' },
  cardPlate: { fontSize: 22, fontWeight: '900', color: COLORS.secondary },
  cardStand: { fontSize: 14, color: '#666', fontWeight: '500' },
  cardTags: { flexDirection: 'row', gap: 8, marginTop: 6 },
  tagPremium: { backgroundColor: '#FEF3C7', color: '#D97706', fontSize: 10, fontWeight: 'bold', paddingVertical: 2, paddingHorizontal: 6, borderRadius: 4, overflow: 'hidden' },
  tagLikes: { color: COLORS.red, fontSize: 12, fontWeight: 'bold' },
  tagBusy: { color: COLORS.busy, fontSize: 10, fontWeight: 'bold', backgroundColor: '#FEE2E2', paddingHorizontal:6, borderRadius:4 },
  callButton: { backgroundColor: COLORS.secondary, padding: 16, borderRadius: 16, flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 8 },
  callButtonText: { color: 'white', fontWeight: 'bold', fontSize: 16 },

  // Modal
  modalOverlay: { flex: 1, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'flex-end' },
  modalContent: { backgroundColor: 'white', height: '60%', borderTopLeftRadius: 30, borderTopRightRadius: 30 },
  modalHeader: { padding: 20, borderBottomWidth: 1, borderBottomColor: '#eee', flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', backgroundColor: COLORS.primary, borderTopLeftRadius: 30, borderTopRightRadius: 30 },
  modalTitle: { fontWeight: 'bold', fontSize: 18 },
  listItem: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: 16, borderBottomWidth: 1, borderBottomColor: '#f0f0f0' },
  listIconBox: { width: 40, height: 40, backgroundColor: '#FFFBEB', borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  listPlate: { fontWeight: 'bold', fontSize: 16 },
  listStand: { fontSize: 12, color: '#666' },

  // Login
  loginContainer: { flex: 1, backgroundColor: '#F3F4F6', justifyContent: 'center', padding: 20 },
  backButton: { marginBottom: 20, marginTop: Platform.OS === 'android' ? 20 : 0 },
  loginCard: { backgroundColor: 'white', borderRadius: 30, padding: 30, shadowColor: "#000", shadowOpacity: 0.1, shadowRadius: 20 },
  loginHeader: { alignItems: 'center', marginBottom: 30 },
  loginTitle: { fontSize: 24, fontWeight: '900', marginBottom: 4 },
  loginSubtitle: { color: '#666' },
  input: { backgroundColor: '#F9FAFB', padding: 16, borderRadius: 16, borderWidth: 1, borderColor: '#E5E7EB', fontWeight: 'bold', fontSize: 16, marginBottom: 10 },
  inputLabel: { fontSize: 12, fontWeight:'bold', color: '#666', marginBottom:5, marginLeft:5},
  loginButton: { backgroundColor: COLORS.secondary, padding: 18, borderRadius: 16, alignItems: 'center', marginTop: 8 },
  loginButtonText: { color: 'white', fontWeight: '900', fontSize: 16 },
  whatsappButton: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', marginTop: 20, padding: 15, borderWidth: 1, borderColor: COLORS.green, borderRadius: 16, borderStyle: 'dashed', backgroundColor: '#F0FDF4' },

  // Admin
  adminContainer: { flex: 1, backgroundColor: '#F9FAFB' },
  adminHeader: { padding: 16, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  adminTitle: { color: 'white', fontWeight: 'bold', fontSize: 18 },
  logoutButtonSmall: { backgroundColor: COLORS.red, padding: 6, borderRadius: 6 },
  tabs: { flexDirection: 'row', backgroundColor: 'white', padding: 4 },
  tabItem: { flex: 1, paddingVertical: 12, alignItems: 'center' },
  tabActive: { borderBottomWidth: 3, borderBottomColor: COLORS.primary },
  tabText: { fontSize: 12, fontWeight: 'bold', color: '#9CA3AF' },
  tabTextActive: { color: COLORS.primary },
  adminContent: { padding: 16 },
  adminCard: { backgroundColor: 'white', padding: 16, borderRadius: 16, marginBottom: 16 },
  cardSectionTitle: { fontWeight: 'bold', marginBottom: 12 },
  miniInput: { backgroundColor: '#F3F4F6', padding: 10, borderRadius: 8, fontSize: 12 },
  addButton: { backgroundColor: COLORS.secondary, padding: 12, borderRadius: 8, alignItems: 'center', marginTop: 8, flexDirection: 'row', justifyContent: 'center' },
  driverRow: { backgroundColor: 'white', padding: 16, borderRadius: 12, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8, borderWidth: 1, borderColor: '#eee' },
  rowTitle: { fontWeight: 'bold', fontSize: 16 },
  rowSubtitle: { fontSize: 12, color: '#666' },
  iconBtn: { padding: 8, borderRadius: 8, marginLeft: 5 },
  requestCard: { backgroundColor: 'white', padding: 16, borderRadius: 12, borderLeftWidth: 4, borderLeftColor: COLORS.primary, marginBottom: 8 },
  reqBtn: { flex: 1, alignItems: 'center', padding: 8, borderRadius: 6 },

  // Driver Panel
  driverContainer: { flex: 1, backgroundColor: '#F3F4F6' },
  driverHeader: { backgroundColor: COLORS.primary, padding: 30, paddingBottom: 40, borderBottomLeftRadius: 40, borderBottomRightRadius: 40 },
  driverPlate: { fontSize: 32, fontWeight: '900' },
  driverStatusText: { fontSize: 16, fontWeight: 'bold', marginTop: 4 },
  headerIconBtn: { backgroundColor: 'rgba(255,255,255,0.3)', padding: 10, borderRadius: 20 },
  driverBody: { flex: 1, padding: 20 },
  statusGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 15 },
  statusBtn: { width: '47%', padding: 20, borderRadius: 20, alignItems: 'center', justifyContent: 'center', gap: 10, elevation: 2 },
  statRow: { flexDirection: 'row', gap: 20, marginTop: 20 },
  statBox: { backgroundColor: 'white', padding: 20, borderRadius: 20, alignItems: 'center', flex: 1, elevation: 2 },
  statVal: { fontSize: 24, fontWeight: '900' },
  statLabel: { fontSize: 10, fontWeight: 'bold', color: '#999' },
});