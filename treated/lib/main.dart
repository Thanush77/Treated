import 'dart:convert';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:excel/excel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Towards Sustainable Solutions',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// LoginPage Widget


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // To show loading indicator during login

  // Login method
  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loader
    });

    final url = Uri.parse('http://localhost:3000/api/login'); // Replace with your backend URL/IP

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );

        // Navigate to home page upon successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to server')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Towards Sustainable Solutions'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 8,
                child: Container(
                  width: math.min(MediaQuery.of(context).size.width * 0.9, 400),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  backgroundColor: Colors.blue[800],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Add sign up functionality or navigation
                },
                child: const Text(
                  'Not yet registered? Sign up now',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}


// HomePage Widget (after login)

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Towards Sustainable Solutions'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactUsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CarouselSlider(
                  items: [
                    GestureDetector(
                      onTap: () =>
                          _launchURL('https://kspcb.karnataka.gov.in/'),
                      child: Image.asset('assets/image.png', fit: BoxFit.cover),
                    ),
                    GestureDetector(
                      onTap: () => _launchURL(
                          'https://indianexpress.com/article/cities/bangalore/treated-sewage-water-for-construction-karnataka-pollution-board-approaches-bis-to-fix-parameters-8140721/#:~:text=%2C%E2%80%9D%20he%20said.-,As%20part%20of%20discouraging%20the%20use%20of%20groundwater%20and%20water,construction%20purposes%20in%20the%20city./'),
                      child: Image.asset('assets/dks.png', fit: BoxFit.cover),
                    ),
                    GestureDetector(
                      onTap: () => _launchURL(
                          'https://www.thehindu.com/news/cities/bangalore/water-woes-apartments-in-bengaluru-can-now-sell-50-of-treated-water-from-in-situ-stps/article67990318.ece'),
                      child: Image.asset('assets/eks.png', fit: BoxFit.cover),
                    ),
                    GestureDetector(
                      onTap: () => _launchURL(
                          'https://welllabs.org/bengalurus-decentralised-sewage-treatment-plants/'),
                      child: Image.asset('assets/gok.png', fit: BoxFit.cover),
                    ),
                  ],
                  options: CarouselOptions(
                    height: 200.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: const Duration(seconds: 2),
                    viewportFraction: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Links',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(Icons.link),
                        title: const Text('Ground water over exploited area'),
                        onTap: () => _launchURL(
                            'https://kspcb.karnataka.gov.in/sites/default/files/inline-files/29%20Notification%20on%20Ground%20Water.pdf'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.link),
                        title: const Text('Standards for Treated water'),
                        onTap: () => _launchURL(
                            'https://mail.google.com/mail/u/0/?tab=rm&ogbl#sent/KtbxLthtFkLVkPWZDqrvwmXfPhBNScGSjB?projector=1&messagePartId=0.1'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.link),
                        title: const Text('Benifits of Selling Treated Water'),
                        onTap: () => _launchURL(
                            'https://www.thehindu.com/news/cities/bangalore/water-woes-apartments-in-bengaluru-can-now-sell-50-of-treated-water-from-in-situ-stps/article67990318.ece'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.link),
                        title: const Text('Draft Liquid waste Gazzte'),
                        onTap: () => _launchURL(
                            ' https://worldtradescanner.com/257748-Liquid%20Waste%20Management%20Rules%202024.pdf'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.link),
                        title: const Text('Borewell Notification '),
                        onTap: () => _launchURL(
                            'https://www.mpcb.gov.in/sites/default/files/water-quality/standards-protocols/Ground_Water_NewGuidelinesNotifiedeng24092021102020.pdf'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.link),
                        title:
                            const Text('KSPCB Initiatives for Water Quality'),
                        onTap: () => _launchURL(
                            'https://kspcb.karnataka.gov.in/sites/default/files/inline-files/new%20stp%20G.pdf'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TreatedWaterPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Use of Treated Water',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//treated water class
class TreatedWaterPage extends StatelessWidget {
  const TreatedWaterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treated Water'),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFB2EBF2),
              Color(0xFF80DEEA),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PDFViewerPage(title: 'Legislative'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  shadowColor: Colors.grey.withOpacity(0.5),
                ),
                child: const Text(
                  'Legislative',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // builder: (context) => const AvailabilityPage(excelFilePath: 'assets/Availabity1.xlsx'),
                      builder: (context) => const AvailabilityPage(
                          excelFilePath: 'assets/Availabity1.xlsx'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  shadowColor: Colors.grey.withOpacity(0.5),
                ),
                child: const Text(
                  'Availability of Treated Water',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NeedForWaterPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  shadowColor: Colors.grey.withOpacity(0.5),
                ),
                child: const Text(
                  'Need For Treated Water',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PDFViewerPage extends StatefulWidget {
  final String title;
  const PDFViewerPage({Key? key, required this.title}) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  Future<void> loadPDF() async {
    try {
      final bytes = await rootBundle.load('assets/Legislative_Govt.pdf');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/legislative.pdf');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue[800],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : localPath != null
              ? PDFView(
                  filePath: localPath!,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  defaultPage: 0,
                  fitPolicy: FitPolicy.BOTH,
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $error')),
                    );
                  },
                  onPageError: (page, error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error on page $page: $error')),
                    );
                  },
                )
              : const Center(
                  child: Text('Failed to load PDF'),
                ),
    );
  }
}
// class AvailabilityPage extends StatefulWidget {
//   const AvailabilityPage({Key? key}) : super(key: key);

//   @override
//   _AvailabilityPageState createState() => _AvailabilityPageState();
// }

// class _AvailabilityPageState extends State<AvailabilityPage> {
//   List<Map<String, dynamic>> _data = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     try {
//       final data = await readExcelFile();
//       setState(() {
//         _data = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load data: $e')),
//         );
//       }
//     }
//   }

//   Future<List<Map<String, dynamic>>> readExcelFile() async {
//     ByteData data = await rootBundle.load('assets/Availabity.xlsx');
//     var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//     var excel = Excel.decodeBytes(bytes);

//     List<Map<String, dynamic>> excelData = [];

//     for (var table in excel.tables.keys) {
//       for (var row in excel.tables[table]!.rows) {
//         if (excel.tables[table]!.rows.indexOf(row) != 0) {
//           Map<String, dynamic> rowData = {
//             // 'slno': row[0]?.value ?? '',
//             'name': row[1]?.value ?? '',
//             'stp_capacity': row[2]?.value ?? '',
//             'color': row[3]?.value ?? '',
//             'location': row[4]?.value ?? '',
//             'comments': row[5]?.value ?? '',
//           };
//           excelData.add(rowData);
//         }
//       }
//     }
//     return excelData;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Availability'),
//         backgroundColor: Colors.blue[800],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _data.isNotEmpty
//               ? SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: SingleChildScrollView(
//                     child: DataTable(
//                       columns: const [
//                         // DataColumn(label: Text('Sl No.')),
//                         DataColumn(label: Text('Name')),
//                         DataColumn(label: Text('STP Capacity')),
//                         DataColumn(label: Text('Color')),
//                         DataColumn(label: Text('Location')),
//                         DataColumn(label: Text('Comments')),
//                       ],
//                       rows: _data.map((row) {
//                         return DataRow(
//                           cells: [
//                             // DataCell(Text(row['slno'].toString())),
//                             DataCell(Text(row['name'].toString())),
//                             DataCell(Text(row['stp_capacity'].toString())),
//                             DataCell(Text(row['color'].toString())),
//                             DataCell(Text(row['location'].toString())),
//                             DataCell(Text(row['comments'].toString())),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 )
//               : const Center(child: Text('No data available')),
//     );
//   }
// }

class AvailabilityPage extends StatefulWidget {
  final String excelFilePath;

  const AvailabilityPage({Key? key, required this.excelFilePath})
      : super(key: key);

  @override
  _AvailabilityPageState createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _loadData(); // Remove this line to prevent automatic loading
  }

  Future<void> _loadData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final File file = File(result.files.single.path!);
        final data = await readExcelFile(file);
        setState(() {
          _allData = data;
          _filteredData = data;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load data: $e')),
          );
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> readExcelFile(File file) async {
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);
    List<Map<String, dynamic>> excelData = [];
    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        if (excel.tables[table]!.rows.indexOf(row) != 0) {
          Map<String, dynamic> rowData = {
            'name': row[1]?.value ?? '',
            'stp_capacity': row[2]?.value ?? '',
            'color': row[3]?.value ?? '',
            'location': row[4]?.value ?? '',
            'comments': row[5]?.value ?? '',
          };
          excelData.add(rowData);
        }
      }
    }
    return excelData;
  }

  void _filterData(String query) {
    setState(() {
      _filteredData = _allData.where((item) {
        return item['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['stp_capacity']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['color']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['location']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['comments']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _loadData,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                controller: _searchController,
                onChanged: _filterData,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredData.isNotEmpty
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: PaginatedDataTable(
                      header: const Text('STP Availability Data'),
                      rowsPerPage: 10,
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('STP Capacity')),
                        DataColumn(label: Text('Color')),
                        DataColumn(label: Text('Location')),
                        DataColumn(label: Text('Comments')),
                      ],
                      source: _DataSource(_filteredData),
                    ),
                  ),
                )
              : const Center(child: Text('No data available')),
    );
  }
}

class _DataSource extends DataTableSource {
  final List<Map<String, dynamic>> _data;

  _DataSource(this._data);

  @override
  DataRow getRow(int index) {
    return DataRow(
      cells: [
        DataCell(Text(_data[index]['name'].toString())),
        DataCell(Text(_data[index]['stp_capacity'].toString())),
        DataCell(Text(_data[index]['color'].toString())),
        DataCell(Text(_data[index]['location'].toString())),
        DataCell(Text(_data[index]['comments'].toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}

class NeedForWaterPage extends StatelessWidget {
  const NeedForWaterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Need for Treated Water'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Project X - 5 KLD'),
            subtitle: Text('Distance: 5 km'),
          ),
          ListTile(
            title: Text('Project Y - 10 KLD'),
            subtitle: Text('Distance: 10 km'),
          ),
          ListTile(
            title: Text('Project Z - 15 KLD'),
            subtitle: Text('Distance: 8 km'),
          ),
        ],
      ),
    );
  }
}

class ContactUsPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Base URL that changes based on platform/environment
  final String baseUrl = Platform.isAndroid 
      ? 'http://10.0.2.2:3000' // Android emulator localhost
      : Platform.isIOS 
          ? 'http://localhost:3000' // iOS simulator
          : 'http://localhost:3000'; // Web/desktop

  ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Background Image
                Center(
                  child: Image.asset(
                    'assets/KSPCB.png', // Make sure this asset exists
                    height: 100,
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24.0),
                
                // Company Address
                const Text(
                  'Address:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  '"Nisarga Bhavan", 3rd Floor,\nThimmaiah road, 7th D Main,\nShivajinagar, Bengaluru - 560079',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16.0),
                
                // Contact Person
                const Text(
                  'Contact Person:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Syed Khaja Mohiddin',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16.0),
                
                // Email
                const Text(
                  'Email:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () => _launchEmail('seoe@kspcb.gov.in'),
                  child: const Text(
                    'seoe@kspcb.gov.in',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                
                // Contact Form
                const Text(
                  'Send us a message:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your message';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: () => _sendEmail(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Could not launch $emailLaunchUri';
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }

  void _sendEmail(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final Uri uri = Uri.parse('$baseUrl/send-email');
      debugPrint('Sending request to: $uri'); // Debug print

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'message': _messageController.text,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      // Hide loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200) {
        // Clear form
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message sent successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw HttpException('Server returned ${response.statusCode}');
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (context.mounted) {
        Navigator.pop(context);
      }

      String errorMessage = 'Failed to send message. ';
      if (e is SocketException) {
        errorMessage += 'Please check your internet connection and try again.';
      } else if (e is TimeoutException) {
        errorMessage += 'Connection timed out. Please try again.';
      } else {
        errorMessage += e.toString();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}