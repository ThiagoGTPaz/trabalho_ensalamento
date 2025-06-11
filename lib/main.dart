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
    _futureEnsalamentos = _carregarEnsalamentosDoDia();
  }

  Future<List<Map<String, dynamic>>> _carregarEnsalamentosDoDia() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hoje = DateTime.now();
      final diaDaSemana = hoje.weekday;

      final diasDaSemana = {
        1: 'segunda',
        2: 'terca',
        3: 'quarta',
        4: 'quinta',
        5: 'sexta',
      };

      final diaAtual = diasDaSemana[diaDaSemana];

      if (diaAtual == null) {
        return []; 
      }

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
          .eq('dia_semana', diaAtual)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text('Aulas do dia - ${widget.curso}'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureEnsalamentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhuma aula agendada para hoje.'),
            );
          }

          final ensalamentos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ensalamentos.length,
            itemBuilder: (context, index) {
              final ensalamento = ensalamentos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ensalamento['materia'] ?? 'Matéria não informada',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Professor: ${ensalamento['professor']?['nome'] ?? 'Não informado'}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sala: ${ensalamento['sala']?['nome'] ?? 'Não informada'}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Horário: ${_formatarHorario(ensalamento['horario'])}',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatarHorario(String? horario) {
    switch (horario) {
      case 'primeiro':
        return 'Primeiro Horário (19:00 - 20:40)';
      case 'segundo':
        return 'Segundo Horário (20:50 - 22:30)';
      default:
        return 'Horário não informado';
    }
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
            curso:cursos(nome)
          ''')
          .eq('professor_id', widget.professorId)
          .order('data_aula');

      return (response as List).cast<Map<String, dynamic>>();
    } catch (error) {
      throw Exception('Erro ao carregar ensalamentos: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text('Aulas - ${widget.professorNome}'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureEnsalamentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma aula agendada.'));
          }

          final ensalamentos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ensalamentos.length,
            itemBuilder: (context, index) {
              final ensalamento = ensalamentos[index];
              final data = DateTime.parse(ensalamento['data_aula'] as String);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ensalamento['materia'] ?? 'Matéria não informada',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Data: ${data.day}/${data.month}/${data.year}'),
                      Text(
                        'Curso: ${ensalamento['curso']?['nome'] ?? 'Não informado'}',
                      ),
                      Text(
                        'Sala: ${ensalamento['sala']?['nome'] ?? 'Não informada'}',
                      ),
                      Text(
                        'Horário: ${_formatarHorario(ensalamento['horario'])}',
                      ),
                      Text(
                        'Semestre: ${ensalamento['semestre'] ?? 'Não informado'}',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatarHorario(String? horario) {
    switch (horario) {
      case 'primeiro':
        return 'Primeiro Horário (19:00 - 20:40)';
      case 'segundo':
        return 'Segundo Horário (20:50 - 22:30)';
      default:
        return 'Horário não informado';
    }
  }
}
