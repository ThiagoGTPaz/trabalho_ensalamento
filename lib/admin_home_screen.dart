import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  // == Botões ==
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Painel do Administrador'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.schedule),
                label: const Text('Ensalamennto'),
                onPressed: () => _abrirFormularioEnsalamennto(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('Lista de Professores'),
                onPressed: () => _abrirListaProfessores(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[900],
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Criar Sala'),
                onPressed: () => _abrirFormularioCriarSala(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.book),
                label: const Text('Adicionar Curso'),
                onPressed: () => _abrirFormularioAdicionarCurso(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editar Sala'),
                onPressed: () => _abrirListaSalas(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('Lista de Cursos'),
                onPressed: () => _abrirListaCursos(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[300],
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Adicionar Professor'),
                onPressed: () => _abrirFormularioAdicionarProfessor(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[500],
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirFormularioEnsalamennto(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EnsalamenntoDialog(),
    );
  }

  void _abrirFormularioCriarSala(BuildContext context) {
    showDialog(context: context, builder: (context) => const CriarSalaDialog());
  }

  void _abrirListaSalas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ListaSalasScreen()),
    );
  }

  void _abrirFormularioAdicionarProfessor(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AdicionarProfessorDialog(), // Sem const
  );
}

void _abrirListaProfessores(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ListaProfessoresScreen()), // Sem const
  );
}

  void _abrirFormularioAdicionarCurso(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AdicionarCursoDialog(),
    );
  }

  void _abrirListaCursos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ListaCursosScreen()),
    );
  }
}

// == Ensalamento ==
class EnsalamenntoDialog extends StatefulWidget {
  const EnsalamenntoDialog({super.key});

  @override
  State<EnsalamenntoDialog> createState() => _EnsalamenntoDialogState();
}

class _EnsalamenntoDialogState extends State<EnsalamenntoDialog> {
  final TextEditingController _materiaController = TextEditingController();
  String? _selectedCurso;
  String? _selectedProfessor;
  String? _selectedHorario;
  int? _selectedSemestre;
  List<Map<String, dynamic>> _filteredSalas = [];
  List<Map<String, dynamic>> _cursos = [];
  List<Map<String, dynamic>> _professores = [];
  bool _isLoading = false;
  bool _isLoadingSalas = false;

  // Checkbox states
  bool _precisaProjetor = false;
  bool _precisaTV = false;
  bool _precisaArCondicionado = false;
  bool _precisaCadeiraPCD = false;
  bool _precisaInformatica = false;
  bool _precisaChromebook = false;
  bool _precisaMA = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cursos = await Supabase.instance.client.from('cursos').select();
      final professores =
          await Supabase.instance.client.from('professores').select();

      setState(() {
        _cursos = (cursos as List).cast<Map<String, dynamic>>();
        _professores = (professores as List).cast<Map<String, dynamic>>();
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

  Future<void> _buscarSalasDisponiveis() async {
    if (_selectedHorario == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um horário')));
      return;
    }

    setState(() {
      _isLoadingSalas = true;
      _filteredSalas = [];
    });

    try {
      // Construir a query base
      var query = Supabase.instance.client.from('salas').select();

      // Adicionar filtros baseados nos checkboxes selecionados
      if (_precisaProjetor) {
        query = query.eq('projetor', true);
      }
      if (_precisaTV) {
        query = query.eq('tv', true);
      }
      if (_precisaArCondicionado) {
        query = query.eq('ar_condicionado', true);
      }
      if (_precisaCadeiraPCD) {
        query = query.eq('cadeira_pcd', true);
      }
      if (_precisaInformatica) {
        query = query.eq('informatica', true);
      }
      if (_precisaChromebook) {
        query = query.eq('chromebook', true);
      }
      if (_precisaMA) {
        query = query.eq('ma', true);
      }

      final result = await query;

      setState(() {
        _filteredSalas = (result as List).cast<Map<String, dynamic>>();
      });
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao buscar salas: $error')));
    } finally {
      setState(() {
        _isLoadingSalas = false;
      });
    }
  }

  Future<void> _salvarEnsalamennto(int salaId) async {
    if (_selectedCurso == null ||
        _selectedProfessor == null ||
        _selectedSemestre == null ||
        _selectedHorario == null ||
        _materiaController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.from('ensalamenntos').insert({
        'curso': _selectedCurso,
        'professor': _selectedProfessor,
        'materia': _materiaController.text.trim(),
        'semestre': _selectedSemestre,
        'horario': _selectedHorario,
        'sala_id': salaId,
      });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ensalamennto salvo com sucesso!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar ensalamennto: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Ensalamennto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              DropdownButtonFormField<String>(
                value: _selectedCurso,
                decoration: const InputDecoration(labelText: 'Curso'),
                items:
                    _cursos.map((curso) {
                      return DropdownMenuItem<String>(
                        value: curso['nome'],
                        child: Text(curso['nome']),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCurso = value;
                    // Filtrar professores pelo curso selecionado
                    _selectedProfessor = null;
                  });
                },
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedProfessor,
                decoration: const InputDecoration(labelText: 'Professor'),
                items:
                    _professores
                        .where(
                          (prof) =>
                              _selectedCurso == null ||
                              prof['curso'] == _selectedCurso,
                        )
                        .map((prof) {
                          return DropdownMenuItem<String>(
                            value: prof['nome'],
                            child: Text(prof['nome']),
                          );
                        })
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProfessor = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _materiaController,
                decoration: const InputDecoration(labelText: 'Matéria'),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                value: _selectedSemestre,
                decoration: const InputDecoration(labelText: 'Semestre'),
                items:
                    List.generate(10, (index) => index + 1).map((semestre) {
                      return DropdownMenuItem<int>(
                        value: semestre,
                        child: Text('$semestre'),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSemestre = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedHorario,
                decoration: const InputDecoration(labelText: 'Horário'),
                items: const [
                  DropdownMenuItem(
                    value: 'primeiro',
                    child: Text('Primeiro Horário'),
                  ),
                  DropdownMenuItem(
                    value: 'segundo',
                    child: Text('Segundo Horário'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedHorario = value;
                  });
                },
              ),

              const SizedBox(height: 16),
              const Text(
                'Recursos necessários:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Projetor'),
                    selected: _precisaProjetor,
                    onSelected:
                        (value) => setState(() => _precisaProjetor = value),
                  ),
                  FilterChip(
                    label: const Text('TV'),
                    selected: _precisaTV,
                    onSelected: (value) => setState(() => _precisaTV = value),
                  ),
                  FilterChip(
                    label: const Text('Ar Cond.'),
                    selected: _precisaArCondicionado,
                    onSelected:
                        (value) =>
                            setState(() => _precisaArCondicionado = value),
                  ),
                  FilterChip(
                    label: const Text('Cadeira PCD'),
                    selected: _precisaCadeiraPCD,
                    onSelected:
                        (value) => setState(() => _precisaCadeiraPCD = value),
                  ),
                  FilterChip(
                    label: const Text('Informática'),
                    selected: _precisaInformatica,
                    onSelected:
                        (value) => setState(() => _precisaInformatica = value),
                  ),
                  FilterChip(
                    label: const Text('Chromebook'),
                    selected: _precisaChromebook,
                    onSelected:
                        (value) => setState(() => _precisaChromebook = value),
                  ),
                  FilterChip(
                    label: const Text('M.A.'),
                    selected: _precisaMA,
                    onSelected: (value) => setState(() => _precisaMA = value),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _buscarSalasDisponiveis,
                child: const Text('Buscar Salas Disponíveis'),
              ),

              const SizedBox(height: 16),

              if (_isLoadingSalas)
                const Center(child: CircularProgressIndicator())
              else if (_filteredSalas.isNotEmpty)
                ..._filteredSalas.map((sala) {
                  return Card(
                    child: ListTile(
                      title: Text(sala['nome']),
                      subtitle: Text(
                        'Capacidade: ${sala['capacidade']}\n'
                        'Recursos: ${[if (sala['projetor']) 'Projetor', if (sala['tv']) 'TV', if (sala['ar_condicionado']) 'Ar Cond.', if (sala['cadeira_pcd']) 'Cadeira PCD', if (sala['informatica']) 'Informática', if (sala['chromebook']) 'Chromebook', if (sala['ma']) 'M.A.'].join(', ')}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => _salvarEnsalamennto(sala['id']),
                      ),
                    ),
                  );
                }).toList()
              else if (_filteredSalas.isEmpty && _selectedHorario != null)
                const Text(
                  'Nenhuma sala disponível com os filtros selecionados',
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
class AdicionarProfessorDialog extends StatefulWidget {
  const AdicionarProfessorDialog({super.key});

  @override
  State<AdicionarProfessorDialog> createState() => _AdicionarProfessorDialogState();
}

class _AdicionarProfessorDialogState extends State<AdicionarProfessorDialog> {
  final TextEditingController _nomeController = TextEditingController();
  List<String> _cursosSelecionados = [];
  List<Map<String, dynamic>> _todosCursos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarCursos();
  }

  Future<void> _carregarCursos() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await Supabase.instance.client.from('cursos').select();
      setState(() {
        _todosCursos = (response as List).cast<Map<String, dynamic>>();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar cursos: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvarProfessor() async {
    final nome = _nomeController.text.trim();

    if (nome.isEmpty || _cursosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final professorResponse = await Supabase.instance.client
          .from('professores')
          .insert({'nome': nome})
          .select()
          .single();

      final professorId = professorResponse['id'] as int;

      for (final curso in _cursosSelecionados) {
        await Supabase.instance.client.from('professor_curso').insert({
          'professor_id': professorId,
          'curso_nome': curso,
        });
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Professor adicionado com sucesso!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar professor: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Professor'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading && _todosCursos.isEmpty)
              const Center(child: CircularProgressIndicator())
            else ...[
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Professor'),
              ),
              const SizedBox(height: 16),
              const Text('Selecione os cursos:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._todosCursos.map((curso) {
                return CheckboxListTile(
                  title: Text(curso['nome']),
                  value: _cursosSelecionados.contains(curso['nome']),
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _cursosSelecionados.add(curso['nome']);
                      } else {
                        _cursosSelecionados.remove(curso['nome']);
                      }
                    });
                  },
                );
              }).toList(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _salvarProfessor,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Salvar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }
}

class ListaProfessoresScreen extends StatefulWidget {
  const ListaProfessoresScreen({super.key});

  @override
  State<ListaProfessoresScreen> createState() => _ListaProfessoresScreenState();
}

class _ListaProfessoresScreenState extends State<ListaProfessoresScreen> {
  late Future<List<Map<String, dynamic>>> _futureProfessores;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _futureProfessores = _carregarProfessores();
  }

  Future<List<Map<String, dynamic>>> _carregarProfessores() async {
    try {
      final response = await Supabase.instance.client
          .from('professores')
          .select('''
            *,
            professor_curso:professor_curso(curso_nome)
          ''')
          .order('nome');

      return (response as List).cast<Map<String, dynamic>>();
    } catch (error) {
      throw Exception('Erro ao carregar professores: $error');
    }
  }

  Future<void> _excluirProfessor(int id) async {
    setState(() => _isLoading = true);
    
    try {
      await Supabase.instance.client
          .from('professor_curso')
          .delete()
          .eq('professor_id', id);

      await Supabase.instance.client
          .from('professores')
          .delete()
          .eq('id', id);

      setState(() {
        _futureProfessores = _carregarProfessores();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Professor excluído com sucesso!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir professor: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Professores')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureProfessores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum professor encontrado.'));
          }

          final professores = snapshot.data!;

          return ListView.builder(
            itemCount: professores.length,
            itemBuilder: (context, index) {
              final professor = professores[index];
              final cursos = (professor['professor_curso'] as List)
                  .cast<Map<String, dynamic>>()
                  .map((pc) => pc['curso_nome'] as String)
                  .toList();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(professor['nome']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cursos.isNotEmpty)
                        Text('Cursos: ${cursos.join(', ')}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _excluirProfessor(professor['id']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// === Criar Sala ===

class CriarSalaDialog extends StatefulWidget {
  const CriarSalaDialog({super.key});

  @override
  State<CriarSalaDialog> createState() => _CriarSalaDialogState();
}

class _CriarSalaDialogState extends State<CriarSalaDialog> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _capacidadeController = TextEditingController();

  bool _temProjetor = false;
  bool _temTV = false;
  bool _temArCondicionado = false;
  bool _temCadeiraPCD = false;
  bool _isLoading = false;
  bool _temInformatica = false;
  bool _temChromebook = false;
  bool _temMA = false;

  Future<void> _salvarSala() async {
    final nome = _nomeController.text.trim();
    final capacidade = int.tryParse(_capacidadeController.text.trim());

    if (nome.isEmpty || capacidade == null || capacidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await Supabase.instance.client.from('salas').insert([
            {
              'nome': nome,
              'capacidade': capacidade,
              'projetor': _temProjetor,
              'tv': _temTV,
              'ar_condicionado': _temArCondicionado,
              'cadeira_pcd': _temCadeiraPCD,
              'informatica': _temInformatica,
              'chromebook': _temChromebook,
              'ma': _temMA,
            },
          ]).select();

      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sala criada com sucesso!')));
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao criar sala: $error')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Criar Nova Sala'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome da Sala'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _capacidadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Capacidade de Alunos',
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Projetor'),
              value: _temProjetor,
              onChanged:
                  (value) => setState(() => _temProjetor = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('TV'),
              value: _temTV,
              onChanged: (value) => setState(() => _temTV = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Ar Condicionado'),
              value: _temArCondicionado,
              onChanged:
                  (value) =>
                      setState(() => _temArCondicionado = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Cadeira para PCD'),
              value: _temCadeiraPCD,
              onChanged:
                  (value) => setState(() => _temCadeiraPCD = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Sala de Informática'),
              value: _temInformatica,
              onChanged:
                  (val) => setState(() => _temInformatica = val ?? false),
            ),
            CheckboxListTile(
              title: const Text('Chromebook'),
              value: _temChromebook,
              onChanged: (val) => setState(() => _temChromebook = val ?? false),
            ),
            CheckboxListTile(
              title: const Text('M.A.'),
              value: _temMA,
              onChanged: (val) => setState(() => _temMA = val ?? false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Salvar'),
          onPressed: _isLoading ? null : _salvarSala,
        ),
      ],
    );
  }
}

// === Adicionar Curso ===

class AdicionarCursoDialog extends StatefulWidget {
  const AdicionarCursoDialog({super.key});

  @override
  State<AdicionarCursoDialog> createState() => _AdicionarCursoDialogState();
}

class _AdicionarCursoDialogState extends State<AdicionarCursoDialog> {
  final TextEditingController _cursoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _salvarCurso() async {
    final curso = _cursoController.text.trim();

    if (curso.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe o nome do curso.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.from('cursos').insert({'nome': curso});

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Curso adicionado com sucesso!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar curso: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Curso'),
      content: TextField(
        controller: _cursoController,
        decoration: const InputDecoration(
          labelText: 'Curso + Turno entre "()" ',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _salvarCurso,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Salvar'),
        ),
      ],
    );
  }
}

// === Editar Sala - Lista ===

class ListaSalasScreen extends StatefulWidget {
  const ListaSalasScreen({super.key});

  @override
  State<ListaSalasScreen> createState() => _ListaSalasScreenState();
}

class _ListaSalasScreenState extends State<ListaSalasScreen> {
  late Future<List<Map<String, dynamic>>> _futureSalas;

  @override
  void initState() {
    super.initState();
    _futureSalas = _buscarSalas();
  }

  Future<List<Map<String, dynamic>>> _buscarSalas() async {
    try {
      final result = await Supabase.instance.client.from('salas').select();

      if (result is List) {
        return result.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (error) {
      throw Exception('Erro ao buscar salas: $error');
    }
  }

  void _abrirEditarSala(Map<String, dynamic> sala) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarSalaScreen(sala: sala)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Sala')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureSalas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma sala encontrada.'));
          }

          final salas = snapshot.data!;

          return ListView.builder(
            itemCount: salas.length,
            itemBuilder: (context, index) {
              final sala = salas[index];
              return ListTile(
                title: Text(sala['nome'] ?? 'Sem nome'),
                subtitle: Text('Capacidade: ${sala['capacidade']}'),
                trailing: const Icon(Icons.edit),
                onTap: () => _abrirEditarSala(sala),
              );
            },
          );
        },
      ),
    );
  }
}

// === Editar Sala - Formulário ===

class EditarSalaScreen extends StatefulWidget {
  final Map<String, dynamic> sala;

  const EditarSalaScreen({super.key, required this.sala});

  @override
  State<EditarSalaScreen> createState() => _EditarSalaScreenState();
}

class _EditarSalaScreenState extends State<EditarSalaScreen> {
  late TextEditingController _nomeController;
  late TextEditingController _capacidadeController;

  late bool _temProjetor;
  late bool _temTV;
  late bool _temArCondicionado;
  late bool _temCadeiraPCD;
  late bool _temInformatica;
  late bool _temChromebook;
  late bool _temMA;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final sala = widget.sala;
    _nomeController = TextEditingController(
      text: sala['nome']?.toString() ?? '',
    );
    _capacidadeController = TextEditingController(
      text: sala['capacidade']?.toString() ?? '',
    );
    _temProjetor = sala['projetor'] ?? false;
    _temTV = sala['tv'] ?? false;
    _temArCondicionado = sala['ar_condicionado'] ?? false;
    _temCadeiraPCD = sala['cadeira_pcd'] ?? false;
    _temInformatica = sala['informatica'] ?? false;
    _temChromebook = sala['chromebook'] ?? false;
    _temMA = sala['ma'] ?? false;
  }

  Future<void> _salvarAlteracoes() async {
    final nome = _nomeController.text.trim();
    final capacidade = int.tryParse(_capacidadeController.text.trim());

    if (nome.isEmpty || capacidade == null || capacidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data =
          await Supabase.instance.client.from('salas').insert([
            {
              'nome': nome,
              'capacidade': capacidade,
              'projetor': _temProjetor,
              'tv': _temTV,
              'ar_condicionado': _temArCondicionado,
              'cadeira_pcd': _temCadeiraPCD,
              'informatica': _temInformatica,
              'chromebook': _temChromebook,
              'MA': _temMA,
            },
          ]).select();

      // Se quiser, use o `data` aqui (é uma lista de mapas)
      print(data);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sala criada com sucesso!')));
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao criar sala: $error')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _capacidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Sala')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome da Sala'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _capacidadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Capacidade'),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Projetor'),
              value: _temProjetor,
              onChanged: (val) => setState(() => _temProjetor = val ?? false),
            ),
            CheckboxListTile(
              title: const Text('TV'),
              value: _temTV,
              onChanged: (val) => setState(() => _temTV = val ?? false),
            ),
            CheckboxListTile(
              title: const Text('Ar Condicionado'),
              value: _temArCondicionado,
              onChanged:
                  (val) => setState(() => _temArCondicionado = val ?? false),
            ),
            CheckboxListTile(
              title: const Text('Cadeira para PCD'),
              value: _temCadeiraPCD,
              onChanged: (val) => setState(() => _temCadeiraPCD = val ?? false),
            ),
            CheckboxListTile(
              title: const Text('Sala de Informática'),
              value: _temInformatica,
              onChanged:
                  (val) => setState(() => _temInformatica = val ?? false),
            ),
            CheckboxListTile(
              title: const Text('Chromebook'),
              value: _temChromebook,
              onChanged: (val) => setState(() => _temChromebook = val ?? false),
            ),
            CheckboxListTile(
              title: const Text('M.A.'),
              value: _temMA,
              onChanged: (val) => setState(() => _temMA = val ?? false),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _salvarAlteracoes,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
// === Lista de Curso ===

class ListaCursosScreen extends StatefulWidget {
  const ListaCursosScreen({super.key});

  @override
  State<ListaCursosScreen> createState() => _ListaCursosScreenState();
}

class _ListaCursosScreenState extends State<ListaCursosScreen> {
  late Future<List<Map<String, dynamic>>> _futureCursos;

  @override
  void initState() {
    super.initState();
    _futureCursos = _buscarCursos();
  }

  Future<List<Map<String, dynamic>>> _buscarCursos() async {
    final result = await Supabase.instance.client.from('cursos').select();
    return result.cast<Map<String, dynamic>>();
  }

  void _abrirEditarCurso(Map<String, dynamic> curso) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarCursoScreen(curso: curso)),
    ).then((_) {
      // Atualiza a lista após voltar
      setState(() {
        _futureCursos = _buscarCursos();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cursos Cadastrados')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureCursos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum curso encontrado.'));
          }

          final cursos = snapshot.data!;

          return ListView.builder(
            itemCount: cursos.length,
            itemBuilder: (context, index) {
              final curso = cursos[index];
              return ListTile(
                title: Text(curso['nome'] ?? 'Sem nome'),
                trailing: const Icon(Icons.edit),
                onTap: () => _abrirEditarCurso(curso),
              );
            },
          );
        },
      ),
    );
  }
}

// === Editar Curso ===
class EditarCursoScreen extends StatefulWidget {
  final Map<String, dynamic> curso;

  const EditarCursoScreen({super.key, required this.curso});

  @override
  State<EditarCursoScreen> createState() => _EditarCursoScreenState();
}

class _EditarCursoScreenState extends State<EditarCursoScreen> {
  late TextEditingController _nomeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: widget.curso['nome']?.toString() ?? '',
    );
  }
  

  Future<void> _salvarAlteracoes() async {
    final nome = _nomeController.text.trim();
    final id = widget.curso['id'];

    if (nome.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe o nome do curso.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client
          .from('cursos')
          .update({'nome': nome})
          .eq('id', id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Curso atualizado com sucesso!')),
      );

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar curso: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Curso')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome do Curso'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _salvarAlteracoes,
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}

// === Adicionar Professor ===

class EnsalamentoDialog extends StatefulWidget {
  const EnsalamentoDialog({super.key});

  @override
  State<EnsalamentoDialog> createState() => _EnsalamentoDialogState();
}

class _EnsalamentoDialogState extends State<EnsalamentoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _materiaController = TextEditingController();
  String? _selectedCurso;
  String? _selectedProfessor;
  String? _selectedHorario;
  int? _selectedSemestre;
  int? _selectedSalaId;
  List<Map<String, dynamic>> _salasDisponiveis = [];
  List<Map<String, dynamic>> _cursos = [];
  List<Map<String, dynamic>> _professores = [];
  bool _isLoading = false;
  bool _isLoadingSalas = false;

  // Recursos disponíveis
  final Map<String, bool> _recursos = {
    'projetor': false,
    'tv': false,
    'ar_condicionado': false,
    'cadeira_pcd': false,
    'informatica': false,
    'chromebook': false,
    'ma': false,
  };

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    setState(() => _isLoading = true);

    try {
      final cursos = await Supabase.instance.client.from('cursos').select();
      final professores =
          await Supabase.instance.client.from('professores').select();

      setState(() {
        _cursos = (cursos as List).cast<Map<String, dynamic>>();
        _professores = (professores as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _buscarSalasDisponiveis() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHorario == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um horário')));
      return;
    }

    setState(() => _isLoadingSalas = true);

    try {
      // Filtra recursos selecionados
      final recursosSelecionados =
          _recursos.entries.where((e) => e.value).map((e) => e.key).toList();

      // Consulta salas que atendem aos requisitos
      final query = Supabase.instance.client
          .from('salas')
          .select()
          .contains('recursos', recursosSelecionados);

      final result = await query;

      setState(() {
        _salasDisponiveis = (result as List).cast<Map<String, dynamic>>();
        _selectedSalaId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao buscar salas: $e')));
    } finally {
      setState(() => _isLoadingSalas = false);
    }
  }

  Future<void> _salvarEnsalamento() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSalaId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione uma sala')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Filtra recursos selecionados
      final recursosSelecionados =
          _recursos.entries.where((e) => e.value).map((e) => e.key).toList();

      await Supabase.instance.client.from('ensalamento').insert({
        'curso': _selectedCurso,
        'professor': _selectedProfessor,
        'materia': _materiaController.text,
        'semestre': _selectedSemestre,
        'horario': _selectedHorario,
        'sala_id': _selectedSalaId,
        'recursos_necessarios': recursosSelecionados,
      });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ensalamento salvo com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar ensalamento: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Ensalamento'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                // Campo para selecionar curso
                DropdownButtonFormField<String>(
                  value: _selectedCurso,
                  decoration: const InputDecoration(labelText: 'Curso'),
                  items:
                      _cursos.map<DropdownMenuItem<String>>((curso) {
                        return DropdownMenuItem<String>(
                          value: curso['nome'] as String,
                          child: Text(curso['nome'] as String),
                        );
                      }).toList(),
                  onChanged: (value) => setState(() => _selectedCurso = value),
                  validator:
                      (value) => value == null ? 'Selecione um curso' : null,
                ),

                const SizedBox(height: 16),

                // Campo para selecionar professor
                DropdownButtonFormField<String>(
                  value: _selectedProfessor,
                  decoration: const InputDecoration(labelText: 'Professor'),
                  items:
                      _professores.map<DropdownMenuItem<String>>((prof) {
                        return DropdownMenuItem<String>(
                          value: prof['nome'] as String,
                          child: Text(prof['nome'] as String),
                        );
                      }).toList(),
                  onChanged:
                      (value) => setState(() => _selectedProfessor = value),
                  validator:
                      (value) =>
                          value == null ? 'Selecione um professor' : null,
                ),

                const SizedBox(height: 16),

                // Campo para matéria
                TextFormField(
                  controller: _materiaController,
                  decoration: const InputDecoration(labelText: 'Matéria'),
                  validator:
                      (value) => value!.isEmpty ? 'Informe a matéria' : null,
                ),

                const SizedBox(height: 16),

                // Campo para semestre
                DropdownButtonFormField<int>(
                  value: _selectedSemestre,
                  decoration: const InputDecoration(labelText: 'Semestre'),
                  items:
                      List.generate(10, (i) => i + 1).map((semestre) {
                        return DropdownMenuItem(
                          value: semestre,
                          child: Text('$semestre'),
                        );
                      }).toList(),
                  onChanged:
                      (value) => setState(() => _selectedSemestre = value),
                  validator:
                      (value) => value == null ? 'Selecione o semestre' : null,
                ),

                const SizedBox(height: 16),

                // Campo para horário
                DropdownButtonFormField<String>(
                  value: _selectedHorario,
                  decoration: const InputDecoration(labelText: 'Horário'),
                  items: const [
                    DropdownMenuItem(
                      value: 'primeiro',
                      child: Text('Primeiro Horário'),
                    ),
                    DropdownMenuItem(
                      value: 'segundo',
                      child: Text('Segundo Horário'),
                    ),
                  ],
                  onChanged:
                      (value) => setState(() => _selectedHorario = value),
                  validator:
                      (value) => value == null ? 'Selecione o horário' : null,
                ),

                const SizedBox(height: 16),
                const Text(
                  'Recursos Necessários:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Checkboxes para recursos
                Wrap(
                  spacing: 8,
                  children:
                      _recursos.keys.map((recurso) {
                        return FilterChip(
                          label: Text(recurso.replaceAll('_', ' ')),
                          selected: _recursos[recurso]!,
                          onSelected: (selected) {
                            setState(() => _recursos[recurso] = selected);
                          },
                        );
                      }).toList(),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _buscarSalasDisponiveis,
                  child: const Text('Buscar Salas Disponíveis'),
                ),

                if (_isLoadingSalas)
                  const LinearProgressIndicator()
                else if (_salasDisponiveis.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Salas Disponíveis:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ..._salasDisponiveis.map((sala) {
                    return RadioListTile<int>(
                      title: Text(sala['nome']),
                      subtitle: Text('Capacidade: ${sala['capacidade']}'),
                      value: sala['id'],
                      groupValue: _selectedSalaId,
                      onChanged:
                          (value) => setState(() => _selectedSalaId = value),
                    );
                  }),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _salvarEnsalamento,
          child:
              _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Salvar Ensalamento'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _materiaController.dispose();
    super.dispose();
  }
}
