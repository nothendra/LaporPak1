import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedRole;
  bool setuju = false;
  bool passwordVisible = false;
  bool _isLoading = false;

  // ✅ Tambahkan "Admin" tanpa ubah desain
  final List<String> roles = ["Ketua RT", "Warga", "Admin"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffffffff),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff212435)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Masuk Akun",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Color(0xff5e31e2),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Silakan isi data di bawah ini untuk melanjutkan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff000000),
                ),
              ),
              const SizedBox(height: 30),

              // Email
              _buildInputField(
                controller: emailController,
                label: "Alamat Email",
                icon: Icons.mail,
              ),
              const SizedBox(height: 16),

              // Password (dengan toggle 👁️)
              TextField(
                controller: passwordController,
                obscureText: !passwordVisible,
                decoration: InputDecoration(
                  labelText: "Kata Sandi",
                  labelStyle: const TextStyle(color: Color(0xff6135e1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon:
                      const Icon(Icons.lock, color: Color(0xff6135e1)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xff6135e1),
                    ),
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dropdown Role
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xff6135e1), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRole,
                    isExpanded: true,
                    hint: const Text("Pilih Peran"),
                    items: roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(role),
                            const Text(
                              "Pilih",
                              style: TextStyle(color: Color(0xff6135e1)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: setuju,
                    onChanged: (value) {
                      setState(() {
                        setuju = value ?? false;
                      });
                    },
                    activeColor: const Color(0xff5e31e2),
                  ),
                  const Expanded(
                    child: Text(
                      "Saya telah membaca dan menyetujui Kebijakan Privasi serta Syarat dan Ketentuan.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tombol Masuk
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        setuju ? const Color(0xff6236e6) : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: setuju && selectedRole != null && !_isLoading
                      ? () async {
                          setState(() {
                            _isLoading = true;
                          });
                          
                          try {
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            
                            // Attempt to login
                            final success = await authProvider.login(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                            
                            if (success && mounted) {
                              // Get the role from the authenticated user
                              final userRole = authProvider.userRole;
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Masuk berhasil!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              
                              // Navigate based on the role from the backend
                              if (userRole == 'rt') {
                                Navigator.pushReplacementNamed(context, '/rt_home');
                              } else if (userRole == 'warga') {
                                Navigator.pushReplacementNamed(context, '/home');
                              } else if (userRole == 'admin') {
                                Navigator.pushReplacementNamed(context, '/home_admin');
                              }
                            }
                          } catch (e) {
                            // Show error message
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Login gagal: ${e.toString()}"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        }
                      : null,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Masuk",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/signup');
                    },
                    child: const Text(
                      "Daftar di sini",
                      style: TextStyle(
                        color: Color(0xff5e31e2),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Dengan melanjutkan, Anda menyetujui ketentuan yang berlaku.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xff807d7d)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xff6135e1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(icon, color: const Color(0xff6135e1)),
      ),
    );
  }
}
