import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notif =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await _notif.initialize(initSettings);

    // WAJIB UNTUK ANDROID 13+
    final androidPlugin = _notif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'flower_channel',
          'Flower Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notifDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notif.show(0, title, body, notifDetails);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi notifikasi
  await NotificationService.init();

  runApp(const ProviderScope(child: FlowerApp()));
}

class FlowerApp extends StatelessWidget {
  const FlowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      theme: ThemeData(primaryColor: Colors.purple),
    );
  }
}

// PROVIDERS
final pageIndexProvider = StateProvider<int>((ref) => 0);
final categoryProvider = StateProvider<String>((ref) => "All");
final navExtendedProvider = StateProvider<bool>((ref) => true);

// NEW: Cart provider
final cartProvider =
    StateNotifierProvider<CartNotifier, List<Map<String, dynamic>>>(
      (ref) => CartNotifier(),
    );

class CartNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CartNotifier() : super([]);

  void addItem(Map<String, dynamic> item) {
    state = [...state, item];
  }
}

// ===============================================================
// MAIN PAGE (RESPONSIVE NAVIGATION)
// ===============================================================
class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(pageIndexProvider);
    final isExtended = ref.watch(navExtendedProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    final pages = [
      const HomePage(),
      const ExplorePage(),
      const WishlistPage(),
      const ChatPage(),
      const ProfilePage(),
    ];

    // Desktop Navigation
    if (screenWidth >= 800) {
      return Scaffold(
        body: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isExtended ? 200 : 70,
              child: NavigationRail(
                extended: isExtended,
                selectedIndex: index,
                onDestinationSelected: (i) =>
                    ref.read(pageIndexProvider.notifier).state = i,
                labelType: isExtended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.selected,
                selectedIconTheme: const IconThemeData(color: Colors.purple),
                unselectedIconTheme: const IconThemeData(color: Colors.grey),
                leading: IconButton(
                  icon: Icon(
                    isExtended
                        ? Icons.arrow_back_ios_new
                        : Icons.arrow_forward_ios,
                    color: Colors.purple,
                  ),
                  onPressed: () =>
                      ref.read(navExtendedProvider.notifier).state =
                          !isExtended,
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_filled),
                    label: Text("Home"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.explore),
                    label: Text("Explore"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite_border),
                    label: Text("Wishlist"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.chat_bubble_outline),
                    label: Text("Chat"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person),
                    label: Text("Profile"),
                  ),
                ],
              ),
            ),
            Expanded(child: pages[index]),
          ],
        ),
      );
    }

    // Mobile Navigation
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => ref.read(pageIndexProvider.notifier).state = i,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chat",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ===============================================================
// HOME PAGE
// ===============================================================
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController specialController;
  late Animation<double> fadeAnim;
  late Animation<double> scaleAnim;

  late AnimationController discountController;
  late Animation<double> discountFade;
  late Animation<Offset> discountSlide;

  late TextEditingController searchController;

  final List<Map<String, dynamic>> BouquetsList = [
    {
      "title": "Pink Lily Symphony",
      "rating": 4.9,
      "image": "assets/images/flower1.png",
    },
    {
      "title": "The Sweet Escape",
      "rating": 4.9,
      "image": "assets/images/flower2.png",
    },
    {
      "title": "The Windsor Bouquet",
      "rating": 4.9,
      "image": "assets/images/flower3.png",
    },
    {
      "title": "The Royal Pastel",
      "rating": 4.9,
      "image": "assets/images/flower4.png",
    },
    {
      "title": "Moonlit Garden",
      "rating": 4.9,
      "image": "assets/images/flower5.png",
    },
    {
      "title": "The Blue Pearl",
      "rating": 4.9,
      "image": "assets/images/flower6.png",
    },
    {
      "title": "Frost & Flight",
      "rating": 4.9,
      "image": "assets/images/flower7.png",
    },
  ];

  final List<Map<String, dynamic>> weddingList = [
    {
      "title": "Fuschia & Flow wedding",
      "rating": 4.9,
      "image": "assets/images/wedding1.png",
    },
    {
      "title": "Winter Whisper wedding",
      "rating": 4.8,
      "image": "assets/images/wedding2.png",
    },
  ];

  final List<Map<String, dynamic>> indoorList = [
    {"title": "Hydrangea", "rating": 4.9, "image": "assets/images/indoor1.png"},
    {"title": "Kalanchoe", "rating": 4.8, "image": "assets/images/indoor2.png"},
    {"title": "Mini Rose", "rating": 4.9, "image": "assets/images/indoor3.png"},
  ];

  final List<Map<String, dynamic>> outdoorList = [
    {"title": "Marigold", "rating": 4.9, "image": "assets/images/outdoor1.png"},
    {
      "title": "Sunflower",
      "rating": 4.9,
      "image": "assets/images/outdoor2.png",
    },
    {
      "title": "Bougainvillea",
      "rating": 4.8,
      "image": "assets/images/outdoor3.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();

    specialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    fadeAnim = CurvedAnimation(parent: specialController, curve: Curves.easeIn);
    scaleAnim = CurvedAnimation(
      parent: specialController,
      curve: Curves.elasticOut,
    );

    discountController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    discountFade = CurvedAnimation(
      parent: discountController,
      curve: Curves.easeIn,
    );
    discountSlide = Tween(begin: const Offset(0.2, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: discountController, curve: Curves.easeOut),
        );

    specialController.forward();
    discountController.forward();
  }

  @override
  void dispose() {
    specialController.dispose();
    discountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(categoryProvider);

    List<Map<String, dynamic>> currentList;
    if (selectedCategory == "Bouquets") {
      currentList = BouquetsList;
    } else if (selectedCategory == "Wedding") {
      currentList = weddingList;
    } else if (selectedCategory == "Indoor") {
      currentList = indoorList;
    } else if (selectedCategory == "Outdoor") {
      currentList = outdoorList;
    } else {
      currentList = [
        ...BouquetsList,
        ...weddingList,
        ...indoorList,
        ...outdoorList,
      ];
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg1.jpg",
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.25),
            ),
          ),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.purple),
                  const SizedBox(width: 6),
                  const Text(
                    "Jawa Barat, Indonesia",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const SectionTitle(title: "Special Offers"),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FadeTransition(
                      opacity: fadeAnim,
                      child: ScaleTransition(
                        scale: scaleAnim,
                        child: SpecialOfferCard(width: screenWidth * 0.55),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FadeTransition(
                      opacity: fadeAnim,
                      child: SlideTransition(
                        position: discountSlide,
                        child: ModFlo2Card(width: screenWidth * 0.42),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FadeTransition(
                      opacity: discountFade,
                      child: SlideTransition(
                        position: discountSlide,
                        child: ModFlo3Card(width: screenWidth * 0.42),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FadeTransition(
                      opacity: discountFade,
                      child: SlideTransition(
                        position: discountSlide,
                        child: ModFlo4Card(width: screenWidth * 0.42),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const SectionTitle(title: "Recommended For You"),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CategoryChip("All", selectedCategory, ref),
                    CategoryChip("Bouquets", selectedCategory, ref),
                    CategoryChip("Wedding", selectedCategory, ref),
                    CategoryChip("Indoor", selectedCategory, ref),
                    CategoryChip("Outdoor", selectedCategory, ref),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 230,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: currentList.length,
                  itemBuilder: (context, index) {
                    final item = currentList[index];
                    return RecommendedItem(
                      title: item["title"],
                      rating: item["rating"],
                      imageAsset: item["image"],
                      onAddToCart: () {
                        ref.read(cartProvider.notifier).addItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${item['title']} ditambahkan ke keranjang!",
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// OTHER PAGES
// ===============================================================
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("Explore Page"));
}

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("Wishlist Page"));
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Chat Page"));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("Profile Page"));
}

// ===============================================================
// CART PAGE
// ===============================================================
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("Keranjang"),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                "Keranjang masih kosong",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  child: ListTile(
                    leading: Image.asset(item["image"], width: 50, height: 50),
                    title: Text(item["title"]),
                    subtitle: Text("Rating: ${item['rating']}"),
                  ),
                );
              },
            ),
    );
  }
}

// ===============================================================
// COMPONENTS
// ===============================================================
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text("See All", style: TextStyle(color: Colors.purple)),
      ],
    );
  }
}

class _PromoImageCard extends StatelessWidget {
  final String title;
  final String desc;
  final String image;
  final double width;

  const _PromoImageCard({
    required this.title,
    required this.desc,
    required this.image,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
          opacity: 0.9,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.black.withOpacity(0.25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(color: Colors.white)),
            const Spacer(),
            Row(
              children: const [
                Text(
                  "View Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SpecialOfferCard extends StatelessWidget {
  final double width;
  const SpecialOfferCard({super.key, required this.width});
  @override
  Widget build(BuildContext context) => _PromoImageCard(
    title: "Today's Offer",
    desc: "Get Special Offer\nUp to 20%",
    image: "assets/images/modflo.jpg",
    width: width,
  );
}

class ModFlo2Card extends StatelessWidget {
  final double width;
  const ModFlo2Card({super.key, required this.width});
  @override
  Widget build(BuildContext context) => _PromoImageCard(
    title: "Valentine Promo",
    desc: "Get 25% OFF Roses",
    image: "assets/images/modflo2.jpg",
    width: width,
  );
}

class ModFlo3Card extends StatelessWidget {
  final double width;
  const ModFlo3Card({super.key, required this.width});
  @override
  Widget build(BuildContext context) => _PromoImageCard(
    title: "Weekend Sale",
    desc: "Buy 1 Get 1 Flowers",
    image: "assets/images/modflo3.jpg",
    width: width,
  );
}

class ModFlo4Card extends StatelessWidget {
  final double width;
  const ModFlo4Card({super.key, required this.width});
  @override
  Widget build(BuildContext context) => _PromoImageCard(
    title: "New Customer",
    desc: "Extra 10% OFF",
    image: "assets/images/modflo4.jpg",
    width: width,
  );
}

class CategoryChip extends StatelessWidget {
  final String text;
  final String selected;
  final WidgetRef ref;
  const CategoryChip(this.text, this.selected, this.ref, {super.key});

  @override
  Widget build(BuildContext context) {
    final active = text == selected;
    return GestureDetector(
      onTap: () => ref.read(categoryProvider.notifier).state = text,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.purple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// RECOMMENDED ITEM (Button Beli DIBUAT BULAT + NOTIFIKASI)
// ===============================================================
class RecommendedItem extends StatelessWidget {
  final String title;
  final double rating;
  final String imageAsset;
  final VoidCallback onAddToCart;

  const RecommendedItem({
    super.key,
    required this.title,
    required this.rating,
    required this.imageAsset,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 160,
          margin: const EdgeInsets.only(right: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(child: Image.asset(imageAsset, fit: BoxFit.cover)),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  Text(rating.toString()),
                ],
              ),
              const SizedBox(height: 8),

              /// ===== BUTTON BELI BULAT (PILL) =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Panggil callback asli (menambahkan ke cart)
                    onAddToCart();

                    // Tampilkan notifikasi lokal
                    NotificationService.showNotification(
                      "Produk Ditambahkan",
                      "$title ditambahkan ke keranjang.",
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // *** BULAT ***
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    "Beli",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              // Panggil callback asli (menambahkan ke cart)
              onAddToCart();

              // Tampilkan notifikasi lokal
              NotificationService.showNotification(
                "Ditambahkan",
                "$title berhasil ditambahkan!",
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}
