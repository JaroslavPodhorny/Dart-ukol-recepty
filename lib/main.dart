import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recepty',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> nakupniSeznam = [];
  String hledanyText = '';

  final recepty = [
    {
      'nazev': 'Špagety',
      'kategorie': 'Hlavní jídlo',
      'cas': 30,
      'porce': 2,
      'ingredience': ['200g špagety', '2ks rajčata', '1ks cibule'],
      'postup': ['Uvařit těstoviny', 'Osmažit cibulku', 'Přidat rajčata'],
    },
    {
      'nazev': 'Palačinky',
      'kategorie': 'Dezert',
      'cas': 20,
      'porce': 4,
      'ingredience': ['2 vejce', '200ml mléko', '150g mouka'],
      'postup': ['Smíchat všechny suroviny', 'Smažit na pánvi'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Moje Recepty'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.restaurant_menu), text: 'Recepty'),
              Tab(icon: Icon(Icons.shopping_cart), text: 'Nákupní seznam'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Seznam receptů
            buildRecipeList(),
            // Nákupní seznam
            buildShoppingList(),
          ],
        ),
      ),
    );
  }

  Widget buildRecipeList() {
    var filtrovaneRecepty = recepty.where((recept) {
      if (hledanyText.isEmpty) return true;
      return recept['nazev']!.toString().toLowerCase().contains(
            hledanyText.toLowerCase(),
          ) ||
          recept['kategorie']!.toString().toLowerCase().contains(
            hledanyText.toLowerCase(),
          );
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Hledat recept',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (text) => setState(() => hledanyText = text),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtrovaneRecepty.length,
            itemBuilder: (context, index) {
              final recept = filtrovaneRecepty[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(recept['nazev'].toString()),
                  subtitle: Text(
                    '${recept['kategorie']} • ${recept['cas']} min • ${recept['porce']} porce',
                  ),
                  onTap: () => showRecipeDetail(recept),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void showRecipeDetail(Map<String, dynamic> recept) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recept['nazev'].toString()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingredience:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...List<String>.from(
                recept['ingredience'],
              ).map((i) => Text('• $i')),
              const SizedBox(height: 16),
              const Text(
                'Postup:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...List<String>.from(recept['postup']).map(
                (krok) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${recept['postup'].indexOf(krok) + 1}. $krok'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                nakupniSeznam.addAll(List<String>.from(recept['ingredience']));
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Přidáno do nákupního seznamu')),
              );
            },
            child: const Text('Přidat do nákupního seznamu'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zavřít'),
          ),
        ],
      ),
    );
  }

  Widget buildShoppingList() {
    return Column(
      children: [
        Expanded(
          child: nakupniSeznam.isEmpty
              ? const Center(child: Text('Nákupní seznam je prázdný'))
              : ListView.builder(
                  itemCount: nakupniSeznam.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key('item_${index}_${nakupniSeznam[index]}'),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        setState(() {
                          nakupniSeznam.removeAt(index);
                        });
                      },
                      child: ListTile(title: Text(nakupniSeznam[index])),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Přidat položku',
                    hintText: 'Zadejte název položky',
                  ),
                  onSubmitted: (text) {
                    if (text.isNotEmpty) {
                      setState(() {
                        nakupniSeznam.add(text);
                      });
                    }
                  },
                ),
              ),
              if (nakupniSeznam.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Vymazat seznam?'),
                        content: const Text(
                          'Opravdu chcete vymazat celý nákupní seznam?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Ne'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                nakupniSeznam.clear();
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Ano'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
