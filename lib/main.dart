import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:trabalho_gustavo/admin_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialize o Supabase com os valores de variáveis de ambiente
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

  // Método de login utilizando Supabase
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
}
 else {
        // Vai pra dashboard ou outra tela
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

  // Navegar para a tela de informações do aluno
  void _goToAlunoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AlunoInfoScreen()),
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
                'Acesso para Professores e Administradores',
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

  final List<String> _cursos = [
    'Análise e Desenvolvimento de Sistemas',
    'Administração',
    'Direito',
    'Enfermagem',
    'Engenharia Civil',
    'Psicologia',
  ];

  final List<String> _semestres = [
    '1º Semestre',
    '2º Semestre',
    '3º Semestre',
    '4º Semestre',
    '5º Semestre',
    '6º Semestre',
    '7º Semestre',
    '8º Semestre',
  ];

  // Método de confirmação para inserir dados do aluno
  void _confirmar() async {
    if (_cursoSelecionado != null && _semestreSelecionado != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final supabase = Supabase.instance.client;

        final response = await supabase.from('alunos').insert({
          'curso': _cursoSelecionado,
          'semestre': _semestreSelecionado,
          'criado_em': DateTime.now().toIso8601String(),
        });

        if (response.error != null) {
          throw response.error!.message;
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
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $error')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione curso e semestre')),
      );
    }
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
        child: Column(
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
                        (curso) =>
                            DropdownMenuItem(value: curso, child: Text(curso)),
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
                          child: Text(semestre),
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
              onPressed: _isLoading ? null : _confirmar,
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
                      : const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}

class AlunoScreen extends StatelessWidget {
  final String curso;
  final String semestre;

  const AlunoScreen({super.key, required this.curso, required this.semestre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Área do Aluno'),
      ),
      body: Center(
        child: Text(
          'Bem-vindo, Aluno do curso $curso,\ndo semestre $semestre!',
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
