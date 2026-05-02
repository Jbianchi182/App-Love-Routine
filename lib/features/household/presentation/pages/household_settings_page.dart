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
    final currentUser = ref.watch(authProvider);
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
          const SizedBox(height: 8),
          Text(
            'Logado como: ${currentUser?.email ?? 'Sem e-mail'}',
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
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
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => ref.invalidate(householdProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Já fui convidado? Clique aqui para atualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseholdDetails(dynamic household, ThemeData theme) {
    final currentUser = ref.read(authProvider);
    final isOwner = household.ownerId == currentUser?.uid;
    
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
                    enabled: isOwner,
                    decoration: InputDecoration(
                      labelText: 'Nome da Residência',
                      border: isOwner ? const UnderlineInputBorder() : InputBorder.none,
                    ),
                    onSubmitted: (val) {
                      if (isOwner) ref.read(householdProvider.notifier).updateName(val);
                    },
                  ),
                ),
                if (isOwner)
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
                // Note: We don't have UID for all emails yet, so we compare emails where possible
                // or use ownerId if we had ownerEmail. For now, let's keep it simple.
                final isHouseholdOwner = household.ownerId == currentUser?.uid && isMe;
                
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(email),
                  subtitle: Text(isMe ? 'Você' : 'Membro'),
                  trailing: isHouseholdOwner 
                    ? const Chip(label: Text('Dono', style: TextStyle(fontSize: 10)))
                    : (isOwner && !isMe ? IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => ref.read(householdProvider.notifier).removeMember('', email),
                      ) : null),
                );
              }),
              if (isOwner) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_add_alt_1_outlined),
                  title: const Text('Convidar Membro'),
                  onTap: () => _showInviteDialog(context),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Sharing Permissions Section
        const Text(
          'Módulos Compartilhados',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _buildSharingTile('shopping', 'Lista de Compras', Icons.shopping_cart_outlined, household, isOwner),
              _buildSharingTile('finance', 'Finanças', Icons.attach_money, household, isOwner),
              _buildSharingTile('diet', 'Dieta e Jejum', Icons.restaurant_menu, household, isOwner),
              _buildSharingTile('health', 'Saúde e Remédios', Icons.favorite_border, household, isOwner),
              _buildSharingTile('education', 'Estudos e Grade', Icons.school_outlined, household, isOwner),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSharingTile(String slug, String title, IconData icon, dynamic household, bool canEdit) {
    final isShared = household.sharedModules.contains(slug);
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(isShared ? 'Compartilhado com a família' : 'Privado (Só o dono vê)'),
      value: isShared,
      onChanged: canEdit ? (val) {
        ref.read(householdProvider.notifier).toggleModule(slug);
      } : null,
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
