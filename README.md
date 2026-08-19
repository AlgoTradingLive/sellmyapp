# SellMyApp

तयार झालेले (running) Android/iOS apps विकत घेण्या-विकण्यासाठी marketplace app — Flutter + Firebase.

## सध्या काय तयार आहे (MVP Scope)

- Login / Sign Up (Email + Password — Firebase Auth)
- Home / Browse screen — category नुसार filter करून सगळे listings बघणे
- App Detail screen — पूर्ण माहिती + Play Store link + WhatsApp वर seller ला संपर्क
- "App विका" फॉर्म — नाव, category, किंमत, description, revenue/downloads, contact
- My Listings — स्वतःच्या listings बघणे / delete करणे

**अजून समाविष्ट नाही (टप्पा २):** in-app chat, payment/escrow, image upload, reviews/ratings, verification badge.

---

## Setup कसं करायचं (स्टेप बाय स्टेप)

### १. Firebase Project तयार करा
1. https://console.firebase.google.com वर जा
2. "Add Project" → नाव द्या (उदा. `sellmyapp`)
3. Project तयार झाल्यावर:
   - **Authentication** → Sign-in method → "Email/Password" enable करा
   - **Firestore Database** → Create database → Production mode
   - **Storage** → गरज नाही (आपण free Cloudinary वापरतो, खाली बघा)

### २. Firestore Security Rules लावा
`firestore.rules` फाईल मधलं rules Firebase Console → Firestore → Rules मध्ये copy-paste करून Publish करा.

### ३. Flutter project ला Firebase जोडा
हे काम **FlutterFlow** किंवा laptop/cloud IDE (उदा. GitHub Codespaces) वरून करावं लागेल, कारण यासाठी FlutterFire CLI लागतो:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

ही command चालवल्यावर आपोआप `lib/firebase_options.dart` फाईल तयार होईल — ती `main.dart` मध्ये import करून
`Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` असं वापरा.

### ४. Dependencies install करा
```bash
flutter pub get
```

### ५. Run करा
```bash
flutter run
```

### ६. Android साठी build करा (Play Store वर टाकण्यासाठी)
```bash
flutter build appbundle --release
```

---

## तुमच्याकडे laptop/desktop नसेल तर (Tablet-only setup)

1. **GitHub Codespaces** वापरा — या repo मध्ये "Code" → "Codespaces" → "Create codespace" — पूर्ण browser मधून Flutter environment मिळेल
2. किंवा **FlutterFlow** (flutterflow.io) वर हे screens आणि Firebase structure बघून तसाच project बनवा — तिथे drag-and-drop UI आहे
3. Build झालेला APK download करण्यासाठी **Codemagic** (codemagic.io) सारखी free CI/CD सेवा वापरून हा repo जोडता येतो — तीच cloud मध्ये build करून APK देते

---

## Folder Structure

```
lib/
  main.dart              → App entry point + login/home routing
  models/
    app_listing.dart      → App listing data model
  services/
    auth_service.dart     → Login/Signup logic
    listing_service.dart  → Firestore read/write
  screens/
    login_screen.dart
    home_screen.dart       → Browse/search listings
    app_detail_screen.dart → Full listing detail + contact seller
    add_listing_screen.dart → Seller फॉर्म
    my_listings_screen.dart → Seller च्या स्वतःच्या listings
```

## Cloudinary Setup (Screenshot Upload — Free)

App screenshots एका मोफत सेवेवर (Cloudinary) upload होतात — Firebase Storage ला paid
plan लागतो म्हणून टाळलं.

1. https://cloudinary.com/users/register/free इथे जाऊन मोफत account बनवा (card लागत नाही)
2. Dashboard वर तुमचं **Cloud name** दिसेल — ते note करा
3. Settings (⚙️) → Upload → खाली स्क्रोल करून **"Upload presets"** → **"Add upload preset"**
   - Signing Mode: **Unsigned** करा (हे महत्त्वाचं आहे)
   - Preset name द्या (उदा. `sellmyapp_unsigned`) आणि Save करा
4. `lib/services/storage_service.dart` मध्ये वरचे 2 values भरा:
   ```dart
   static const String cloudName = 'तुमचं cloud name';
   static const String uploadPreset = 'तुमचं preset name';
   ```

## EmailJS Setup (Ownership Verification — Free)

Seller च्या app च्या ownership verify करण्यासाठी त्याच्या Play Store developer
email वर एक code पाठवला जातो — यासाठी EmailJS (मोफत, backend न लागता client
मधून थेट email पाठवता येतो) वापरलंय.

1. https://www.emailjs.com/ वर मोफत account बनवा (card लागत नाही)
2. Dashboard → **Email Services** → **Add New Service** → Gmail (किंवा दुसरी सेवा) जोडा
   → त्याचं **Service ID** note करा
3. Dashboard → **Email Templates** → **Create New Template**. Template मध्ये
   हे variables वापरा: `{{to_email}}`, `{{app_title}}`, `{{code}}`
   (उदा. subject: "Verify ownership of {{app_title}}", body मध्ये code टाका)
   → Save करून **Template ID** note करा
4. Dashboard → **Account** → **General** → **Public Key** note करा
5. `lib/services/verification_service.dart` मध्ये वरचे 3 values भरा:
   ```dart
   static const String emailJsServiceId = 'तुमचं service id';
   static const String emailJsTemplateId = 'तुमचं template id';
   static const String emailJsPublicKey = 'तुमची public key';
   ```



- [ ] Firebase project तयार करून जोडणे
- [x] Screenshot upload (Cloudinary - free tier) जोडलं
- [ ] App icon आणि splash screen
- [ ] Play Store listing तयार करणे
- [x] Search/filter सुधारणे
- [ ] Seller verification badge system
