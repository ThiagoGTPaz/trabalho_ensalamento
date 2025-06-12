import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:trabalho_gustavo/admin_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oksfaqaavvcnczhwmsno.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9rc2ZhcWFhdnZjbmN6aHdtc25vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2ODg5NTcsImV4cCI6MjA2MzI2NDk1N30.W74XL_NBJe5dsvJ1U73ouGL2KU49dVxwrmL5REIkQcw',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha e-mail e senha')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null || user.email == null) {
        throw 'Falha ao autenticar usuário.';
      }

      final userEmail = user.email!;

      if (userEmail.toLowerCase() == 'adm@gmail.com') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro no login: $error')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToAlunoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AlunoInfoScreen()),
    );
  }

  void _goToProfessorScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfessorInfoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Login'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'AchaSala',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://dcdn-us.mitiendanube.com/stores/003/870/753/products/logo_unicv_colorida-c6cd0b69c5ca361b6116989466657002-480-0.png',
                height: 100,
              ),
              const SizedBox(height: 20),
              Text(
                'Acesso para Administradores',
                style: TextStyle(fontSize: 18, color: Colors.green[900]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Entrar'),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 10),
              const Text('Ou', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _goToAlunoScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: const Text('Sou Aluno'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _goToProfessorScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[500],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: const Text('Sou Professor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Dashboard'),
      ),
      body: const Center(
        child: Text(
          'Bem-vindo, Professor/Admin!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class AlunoInfoScreen extends StatefulWidget {
  const AlunoInfoScreen({super.key});

  @override
  State<AlunoInfoScreen> createState() => _AlunoInfoScreenState();
}

class _AlunoInfoScreenState extends State<AlunoInfoScreen> {
  String? _cursoSelecionado;
  String? _semestreSelecionado;
  bool _isLoading = false;
  List<Map<String, dynamic>> _cursos = [];
  List<String> _semestres = [];

  @override
  void initState() {
    super.initState();
    _carregarCursosESemestres();
  }

  Future<void> _carregarCursosESemestres() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cursosResponse = await Supabase.instance.client
          .from('cursos')
          .select('nome')
          .order('nome');

      final semestresResponse = await Supabase.instance.client
          .from('ensalamentos')
          .select('semestre')
          .order('semestre');

      setState(() {
        _cursos = (cursosResponse as List).cast<Map<String, dynamic>>();
        _semestres =
            (semestresResponse as List)
                .cast<Map<String, dynamic>>()
                .map((e) => e['semestre'].toString())
                .toSet()
                .toList()
              ..sort();
      });
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $error')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmar() {
    if (_cursoSelecionado == null || _semestreSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione curso e semestre')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AlunoScreen(
              curso: _cursoSelecionado!,
              semestre: _semestreSelecionado!,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Informações do Aluno'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'AchaSala',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Curso',
                        border: OutlineInputBorder(),
                      ),
                      value: _cursoSelecionado,
                      items:
                          _cursos
                              .map(
                                (curso) => DropdownMenuItem(
                                  value: curso['nome'] as String,
                                  child: Text(curso['nome'] as String),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _cursoSelecionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Semestre',
                        border: OutlineInputBorder(),
                      ),
                      value: _semestreSelecionado,
                      items:
                          _semestres
                              .map(
                                (semestre) => DropdownMenuItem(
                                  value: semestre,
                                  child: Text('$semestreº Semestre'),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _semestreSelecionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _confirmar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
      ),
    );
  }
}

class AlunoScreen extends StatefulWidget {
  final String curso;
  final String semestre;

  const AlunoScreen({super.key, required this.curso, required this.semestre});

  @override
  State<AlunoScreen> createState() => _AlunoScreenState();
}

class _AlunoScreenState extends State<AlunoScreen> {
  late Future<List<Map<String, dynamic>>> _futureEnsalamentos;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _futureEnsalamentos = _carregarEnsalamentos();
  }

  Future<List<Map<String, dynamic>>> _carregarEnsalamentos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('ensalamentos')
          .select('''
            *,
            sala:salas(nome),
            professor:professores(nome),
            curso:cursos(nome)
          ''')
          .eq('curso', widget.curso)
          .eq('semestre', widget.semestre)
          .order('dia_semana')
          .order('horario');

      return (response as List).cast<Map<String, dynamic>>();
    } catch (error) {
      throw Exception('Erro ao carregar ensalamentos: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, Map<String, String>> _organizarEnsalamentosPorDia(
    List<Map<String, dynamic>> ensalamentos,
  ) {
    final Map<String, Map<String, String>> tabela = {
      'segunda': {'primeiro': '', 'segundo': ''},
      'terca': {'primeiro': '', 'segundo': ''},
      'quarta': {'primeiro': '', 'segundo': ''},
      'quinta': {'primeiro': '', 'segundo': ''},
      'sexta': {'primeiro': '', 'segundo': ''},
    };

    for (final ensalamento in ensalamentos) {
      final dia = ensalamento['dia_semana'] as String?;
      final horario = ensalamento['horario'] as String?;
      final sala = ensalamento['sala']?['nome'] as String? ?? '';

      if (dia != null && horario != null && tabela.containsKey(dia)) {
        tabela[dia]![horario] = sala;
      }
    }

    return tabela;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text('Grade Horária - ${widget.curso}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'AchaSala',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureEnsalamentos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhuma aula agendada.'));
            }

            final tabela = _organizarEnsalamentosPorDia(snapshot.data!);
            final diasDaSemana = [
              'segunda',
              'terca',
              'quarta',
              'quinta',
              'sexta',
            ];
            final nomesDias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[300]!, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: DataTable(
                    columnSpacing: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    columns: [
                      DataColumn(
                        label: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Center(
                            child: Text(
                              'Horário',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      ...diasDaSemana.asMap().entries.map((entry) {
                        final index = entry.key;
                        return DataColumn(
                          label: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: Text(
                                nomesDias[index],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          const DataCell(
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('19:00 - 20:40'),
                            ),
                          ),
                          ...diasDaSemana.map((dia) {
                            return DataCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  tabela[dia]!['primeiro']!,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      DataRow(
                        cells: [
                          const DataCell(
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('20:50 - 22:30'),
                            ),
                          ),
                          ...diasDaSemana.map((dia) {
                            return DataCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  tabela[dia]!['segundo']!,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfessorInfoScreen extends StatefulWidget {
  const ProfessorInfoScreen({super.key});

  @override
  State<ProfessorInfoScreen> createState() => _ProfessorInfoScreenState();
}

class _ProfessorInfoScreenState extends State<ProfessorInfoScreen> {
  int? _professorSelecionadoId;
  bool _isLoading = false;
  List<Map<String, dynamic>> _professores = [];

  @override
  void initState() {
    super.initState();
    _carregarProfessores();
  }

  Future<void> _carregarProfessores() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('professores')
          .select('id, nome')
          .order('nome');

      setState(() {
        _professores = (response as List).cast<Map<String, dynamic>>();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar professores: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmar() {
    if (_professorSelecionadoId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um professor')));
      return;
    }

    final professorSelecionado = _professores.firstWhere(
      (prof) => prof['id'] == _professorSelecionadoId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProfessorScreen(
              professorId: _professorSelecionadoId!,
              professorNome: professorSelecionado['nome'],
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Informações do Professor'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'AchaSala',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Professor',
                        border: OutlineInputBorder(),
                      ),
                      value: _professorSelecionadoId,
                      items:
                          _professores
                              .map(
                                (professor) => DropdownMenuItem(
                                  value: professor['id'] as int,
                                  child: Text(professor['nome'] as String),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _professorSelecionadoId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _confirmar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
      ),
    );
  }
}

class ProfessorScreen extends StatefulWidget {
  final int professorId;
  final String professorNome;

  const ProfessorScreen({
    super.key,
    required this.professorId,
    required this.professorNome,
  });

  @override
  State<ProfessorScreen> createState() => _ProfessorScreenState();
}

class _ProfessorScreenState extends State<ProfessorScreen> {
  late Future<List<Map<String, dynamic>>> _futureEnsalamentos;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _futureEnsalamentos = _carregarEnsalamentos();
  }

  Future<List<Map<String, dynamic>>> _carregarEnsalamentos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('ensalamentos')
          .select('''
            *,
            sala:salas(nome),
            curso:cursos(nome),
            professor:professores(nome)
          ''')
          .eq('professor_id', widget.professorId)
          .order('dia_semana')
          .order('horario');

      return (response as List).cast<Map<String, dynamic>>();
    } catch (error) {
      throw Exception('Erro ao carregar ensalamentos: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, Map<String, String>> _organizarEnsalamentosPorDia(
    List<Map<String, dynamic>> ensalamentos,
  ) {
    final Map<String, Map<String, String>> tabela = {
      'segunda': {'primeiro': '', 'segundo': ''},
      'terca': {'primeiro': '', 'segundo': ''},
      'quarta': {'primeiro': '', 'segundo': ''},
      'quinta': {'primeiro': '', 'segundo': ''},
      'sexta': {'primeiro': '', 'segundo': ''},
    };

    for (final ensalamento in ensalamentos) {
      final dia = ensalamento['dia_semana'] as String?;
      final horario = ensalamento['horario'] as String?;
      final materia = ensalamento['materia'] as String? ?? '';
      final sala = ensalamento['sala']?['nome'] as String? ?? '';
      final curso = ensalamento['curso']?['nome'] as String? ?? '';

      final info = '$materia\n$sala\n$curso';

      if (dia != null && horario != null && tabela.containsKey(dia)) {
        tabela[dia]![horario] = info;
      }
    }

    return tabela;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text('Grade Horária - ${widget.professorNome}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'AchaSala',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureEnsalamentos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhuma aula agendada.'));
            }

            final tabela = _organizarEnsalamentosPorDia(snapshot.data!);
            final diasDaSemana = [
              'segunda',
              'terca',
              'quarta',
              'quinta',
              'sexta',
            ];
            final nomesDias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[300]!, width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: DataTable(
                    columnSpacing: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    columns: [
                      DataColumn(
                        label: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(
                            'Horário',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ...diasDaSemana.asMap().entries.map((entry) {
                        final index = entry.key;
                        return DataColumn(
                          label: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              nomesDias[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          const DataCell(
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('19:00 - 20:40'),
                            ),
                          ),
                          ...diasDaSemana.map((dia) {
                            return DataCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 1,
                                ),
                                child: Text(
                                  tabela[dia]!['primeiro']!.isNotEmpty
                                      ? tabela[dia]!['primeiro']!
                                      : '-',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        tabela[dia]!['primeiro']!.isNotEmpty
                                            ? Colors.green[800]
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      DataRow(
                        cells: [
                          const DataCell(
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('20:50 - 22:30'),
                            ),
                          ),
                          ...diasDaSemana.map((dia) {
                            return DataCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 1,
                                ),
                                child: Text(
                                  tabela[dia]!['segundo']!.isNotEmpty
                                      ? tabela[dia]!['segundo']!
                                      : '-',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        tabela[dia]!['segundo']!.isNotEmpty
                                            ? Colors.green[800]
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
