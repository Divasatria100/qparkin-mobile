// 📄 lib/presentation/screens/tambah_kendaraan.dart
import 'package:flutter/material.dart';

class VehicleSelectionPage extends StatefulWidget {
  const VehicleSelectionPage({super.key});

  @override
  State<VehicleSelectionPage> createState() => _VehicleSelectionPageState();
}

class _VehicleSelectionPageState extends State<VehicleSelectionPage> {
  String? selectedVehicle;
  final TextEditingController brandController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController customerTypeController = TextEditingController();
  String? selectedCustomerType;
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _loadCustomerType();
  }

  Future<void> _loadCustomerType() async {
    setState(() {
      selectedCustomerType = "Operasional";
      customerTypeController.text = "Operasional";
    });
  }

  final List<Map<String, String>> vehicles = [
    {"name": "Roda Dua", "image": "assets/images/scooter 1.png"},
    {"name": "Roda Empat", "image": "assets/images/image 4.png"},
    {"name": "Roda Enam", "image": "assets/images/image 5.png"},
    {"name": "Roda Delapan", "image": "assets/images/image 6.png"},
  ];

  final List<String> customerTypes = ["Operasional", "Kantor", "Perusahaan"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header sama dengan list_kendaraan.dart
              Container(
                width: double.infinity,
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF42CBF8),
                      Color(0xFF573ED1),
                      Color(0xFF39108A),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Image.asset(
                      'assets/images/qparkin.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Jenis Kendaraan",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),

                    // 🔸 Grid Kendaraan
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 29,
                        crossAxisSpacing: 22,
                        childAspectRatio: 137 / 67,
                      ),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        final isSelected =
                            selectedVehicle == vehicle["name"];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedVehicle = vehicle["name"];
                            });
                          },
                          child: Container(
                            height: 67,
                            padding:
                                const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF3A0CA3)
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Image.asset(
                                      vehicle["image"]!,
                                      width: 35,
                                      height: 35,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          Icon(Icons.directions_car,
                                              size: 30,
                                              color: isSelected
                                                  ? const Color(0xFF3A0CA3)
                                                  : Colors.grey.shade600),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  vehicle["name"]!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFF3A0CA3)
                                        : const Color(0xFFA5AAB7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 45),

                    // 🔸 Input Merek Kendaraan
                    TextField(
                      controller: brandController,
                      decoration: const InputDecoration(
                        labelText: "Pilih Merek Kendaraan",
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF3D9AE2)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF3D9AE2), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 🔸 Input Nomor Kendaraan
                    TextField(
                      controller: plateController,
                      decoration: const InputDecoration(
                        labelText: "Masukkan No Kendaraan",
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF3D9AE2)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF3D9AE2), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 🔸 Custom Dropdown tipe customer
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isDropdownOpen = !isDropdownOpen;
                        });
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: customerTypeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Pilih Tipe Customer",
                            enabledBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(0xFF3D9AE2)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFF3D9AE2), width: 2),
                            ),
                            suffixIcon: AnimatedRotation(
                              turns: isDropdownOpen ? 0.5 : 0,
                              duration:
                                  const Duration(milliseconds: 300),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF3D9AE2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 🔸 Dropdown Menu
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: isDropdownOpen
                          ? Container(
                              key: const ValueKey('dropdown'),
                              margin: const EdgeInsets.only(
                                  top: 12, bottom: 20),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FF),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: customerTypes.map((type) {
                                  final isSelected =
                                      selectedCustomerType == type;
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedCustomerType = type;
                                          customerTypeController.text = type;
                                          isDropdownOpen = false;
                                        });
                                      },
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF3A0CA3)
                                                : Colors.transparent,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.03),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          type,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? const Color(0xFF3A0CA3)
                                                : const Color(0xFF999999),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 60),

                    // 🔸 Tombol Tambahkan
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 37,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedVehicle == null ||
                                brandController.text.isEmpty ||
                                plateController.text.isEmpty ||
                                selectedCustomerType == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Lengkapi semua data terlebih dahulu"),
                                ),
                              );
                              return;
                            }

                            final newVehicle = {
                              'name':
                                  "${brandController.text} (${selectedVehicle ?? ''})",
                              'plate': plateController.text,
                              'icon': Icons.directions_car,
                            };

                            Navigator.pop(context, newVehicle);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Tambahkan",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}