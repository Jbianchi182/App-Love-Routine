import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/household/presentation/providers/household_provider.dart';
import 'package:love_routine_app/features/auth/presentation/providers/auth_provider.dart';

class HouseholdSettingsPage extends ConsumerStatefulWidget {
  const HouseholdSettingsPage({super.key});

  @override
  ConsumerState<HouseholdSettingsPage> createState() => _HouseholdSettingsPageState();
}

class _HouseholdSettingsPageState extends ConsumerState<HouseholdSettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final householdAsync = ref.watch(householdProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Residência'),
      ),
      body: householdAsync.when(
        data: (household) {
          if (household == null) {
            return _buildCreateHousehold(theme);
          }
          _nameController.text = household.name;
          return _buildHouseholdDetails(household, theme);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar: $e')),
      ),
    );
  }

  Widget _buildCreateHousehold(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_outlined, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          const Text(
            'Crie sua Residência',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Para compartilhar informações com sua família, crie um espaço compartilhado.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome da Residência',
              hintText: 'Ex: Casa dos Silva, Nosso Lar...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SProject(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  ref.read(householdProvider.notifier).createHousehold(_nameController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Criar Agora'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseholdDetails(dynamic household, ThemeData theme) {
    final currentUser = ref.read(authProvider);
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Household Name
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Residência',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (val) {
                      ref.read(householdProvider.notifier).updateName(val);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    ref.read(householdProvider.notifier).updateName(_nameController.text);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Members Section
        const Text(
          'Membros da Família',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ...household.memberEmails.map((email) {
                final isMe = email == currentUser?.email;
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(email),
                  subtitle: Text(isMe ? 'Proprietário' : 'Membro'),
                  trailing: isMe ? null : IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () {
                      ref.read(householdProvider.notifier).removeMember('', email);
                    },
                  ),
                );
              }),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: const Text('Convidar Membro'),
                onTap: () => _showInviteDialog(context),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Sharing Permissions Section
        const Text(
          'O que compartilhar?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _buildSharingTile('shopping', 'Lista de Compras', Icons.shopping_cart_outlined, household),
              _buildSharingTile('finance', 'Finanças', Icons.attach_money, household),
              _buildSharingTile('diet', 'Dieta e Jejum', Icons.restaurant_menu, household),
              _buildSharingTile('health', 'Saúde e Remédios', Icons.favorite_border, household),
              _buildSharingTile('education', 'Estudos e Grade', Icons.school_outlined, household),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSharingTile(String slug, String title, IconData icon, dynamic household) {
    final isShared = household.sharedModules.contains(slug);
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(isShared ? 'Compartilhado com a família' : 'Privado (Só eu vejo)'),
      value: isShared,
      onChanged: (val) {
        ref.read(householdProvider.notifier).toggleModule(slug);
      },
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convidar por E-mail'),
        content: TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'E-mail do Membro',
            hintText: 'exemplo@gmail.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_emailController.text.isNotEmpty) {
                ref.read(householdProvider.notifier).addMember(_emailController.text);
                _emailController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Convidar'),
          ),
        ],
      ),
    );
  }
}

// Simple wrapper to fix ElevatedButton sizing
class SProject extends StatelessWidget {
  final Widget child;
  final double? width;
  const SProject({super.key, required this.child, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: child);
  }
}
